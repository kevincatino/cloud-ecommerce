import axios from "axios";
import { API_BASE } from "src/constants";


const axiosInstance = axios.create({
  baseURL: API_BASE, // Set your backend API base URL here
});

// Interceptor to add the JWT token to all requests
axiosInstance.interceptors.request.use((config) => {
  const token = localStorage.getItem('jwtToken'); // Retrieve the token from local storage

  if (token) {
      config.headers['Authorization'] = `Bearer ${token}`; // Set the Bearer token
  }

  return config; // Return the updated config
}, (error) => {
  return Promise.reject(error); // Handle the error
});


class ApiClient {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
  }

  async request(method, path, body) {
    try {
      const response = await axiosInstance({
        method,
        url: `${this.baseUrl}${path}`,
        headers: {
          "Content-Type": "application/json",
        },
        data: body,
      });
      return { error: false, data: response.data };
    } catch (error) {
      console.error(error);
      return { error: true, data: { message: error.message } };
    }
  }

  async getItemList() {
    return await this.request("GET", "/items");
  }

  async getItem(id) {
    return await this.request("GET", `/items/${id}`);
  }

  async modifyItem(id, data) {
    return await this.request("PUT", `/items/${id}`, data);
  }

  async login(username, password) {
    return await this.request("POST", "/login", { username, password });
  }
}

export default ApiClient;
