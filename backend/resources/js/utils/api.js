const API_BASE = '';

export const getAuthHeaders = () => {
  const headers = { 'Accept': 'application/json', 'Content-Type': 'application/json' };
  const token = localStorage.getItem('oasis_token');
  if (token) headers['Authorization'] = `Bearer ${token}`;
  return headers;
};

export const apiFetch = async (url, options = {}) => {
  const headers = getAuthHeaders();
  const fullUrl = url.startsWith('http') ? url : `${API_BASE}${url}`;
  const fetchOptions = { ...options, headers: { ...headers, ...(options.headers || {}) } };
  if (options.body instanceof FormData) delete fetchOptions.headers['Content-Type'];
  return fetch(fullUrl, fetchOptions);
};

export const requestPasswordReset = async (email) => {
  const response = await apiFetch('/api/auth/forgot-password', {
    method: 'POST', body: JSON.stringify({ email }),
  });
  if (!response.ok) { const error = await response.json(); throw { response: { data: error } }; }
  return response.json();
};

export const resetPassword = async (email, token, password, passwordConfirmation) => {
  const response = await apiFetch('/api/auth/reset-password', {
    method: 'POST',
    body: JSON.stringify({ email, token, password, password_confirmation: passwordConfirmation }),
  });
  if (!response.ok) { const error = await response.json(); throw { response: { data: error } }; }
  return response.json();
};

export const verifyResetToken = async (email, token) => {
  const response = await apiFetch('/api/auth/verify-reset-token', {
    method: 'POST', body: JSON.stringify({ email, token }),
  });
  if (!response.ok) { const error = await response.json(); throw { response: { data: error } }; }
  return response.json();
};
