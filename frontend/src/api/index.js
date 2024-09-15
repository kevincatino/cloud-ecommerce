import axios from "axios";
import { API_KEY } from "src/constants";

class ApiClient {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
  }

  async request(method, path, body) {
    try {
      const response = await axios({
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
