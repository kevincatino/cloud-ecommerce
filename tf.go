package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

// Helper function to execute shell commands
func runCommand(dir string, name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if dir != "" {
		cmd.Dir = dir
	}
	return cmd.Run()
}

// Function to run npm commands for frontend
func buildFrontend() error {
	fmt.Println("Building frontend...")
	frontendDir := "./frontend"

	// Run 'npm install'
	if err := runCommand(frontendDir,"npm", "install"); err != nil {
		return fmt.Errorf("failed to install frontend dependencies: %w", err)
	}

	// Run 'npm run build'
	if err := runCommand(frontendDir,"npm", "run", "build"); err != nil {
		return fmt.Errorf("failed to build frontend: %w", err)
	}

	// Run 'npm run export'
	if err := runCommand(frontendDir,"npm", "run", "export"); err != nil {
		return fmt.Errorf("failed to export frontend: %w", err)
	}

	return nil
}

// Function to check if a file or directory exists
func fileExists(path string) bool {
	_, err := os.Stat(path)
	return !os.IsNotExist(err)
}

// Helper function to run npm install in a directory
func npmInstall(dir string) error {
	fmt.Printf("Running npm install in %s\n", dir)
	cmd := exec.Command("npm", "install")
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}

// Function to iterate over top-level subdirectories and run npm install if package.json exists
func installDependenciesInTopLevelDirs(root string) error {
	// Get all files and directories in the root directory
	files, err := ioutil.ReadDir(root)
	if err != nil {
		return fmt.Errorf("failed to read directory %s: %w", root, err)
	}

	// Loop over the entries
	for _, file := range files {
		// Check if the entry is a directory
		if file.IsDir() {
			dirPath := filepath.Join(root, file.Name())

			// Check if the directory contains a package.json file
			packageJSON := filepath.Join(dirPath, "package.json")
			if fileExists(packageJSON) {
				// Run npm install in this directory
				if err := npmInstall(dirPath); err != nil {
					return fmt.Errorf("failed to install dependencies in %s: %w", dirPath, err)
				}
			}
		}
	}

	return nil
}

// Function to install dependencies for lambdas
func installLambdaDependencies() error {
	fmt.Println("Installing Lambda dependencies...")
	lambdasDir := "./iac/lambda/api"


	if err := installDependenciesInTopLevelDirs(lambdasDir); err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}

	lambdasDir = "./iac/lambda/schema"

	if err := installDependenciesInTopLevelDirs(lambdasDir); err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("Dependencies installed successfully in all subdirectories.")

	return nil
}

// Function to determine if we're on Windows or Unix
func isWindows() bool {
	return runtime.GOOS == "windows"
}

// Function to run Terraform with pre-build tasks
func runTerraformCommand(terraformArgs []string) error {
	terraformArgs = append([]string{"-chdir=iac"},terraformArgs...)
	// Run the npm build commands before terraform plan or apply
	if strings.Contains(strings.Join(terraformArgs, " "), "apply") || strings.Contains(strings.Join(terraformArgs, " "), "plan") {
		if err := buildFrontend(); err != nil {
			return err
		}

		if err := installLambdaDependencies(); err != nil {
			return err
		}
	}

	// If it's destroy, skip the npm steps
	if strings.Contains(strings.Join(terraformArgs, " "), "destroy") {
		fmt.Println("Running terraform destroy...")
	}

	// Run the terraform command
	if err := runCommand("", "terraform", terraformArgs...); err != nil {
		return fmt.Errorf("failed to run terraform command: %w", err)
	}

	return nil
}


// Main function that acts as the entry point
func main() {
	if len(os.Args) < 2 {
		log.Fatalf("Usage: %s [terraform args]", os.Args[0])
	}

	terraformArgs := os.Args[1:]

	if err := runTerraformCommand(terraformArgs); err != nil {
		log.Fatalf("Error: %v", err)
	}
}