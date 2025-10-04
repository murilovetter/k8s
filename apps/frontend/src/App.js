import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [newUser, setNewUser] = useState({ name: '', email: '' });

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await axios.get('/api/users');
      setUsers(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch users');
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post('/api/users', newUser);
      setNewUser({ name: '', email: '' });
      fetchUsers();
    } catch (err) {
      setError('Failed to create user');
      console.error('Error creating user:', err);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`/api/users/${id}`);
      fetchUsers();
    } catch (err) {
      setError('Failed to delete user');
      console.error('Error deleting user:', err);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 Kubernetes Demo - Frontend</h1>
        <p>React + Nginx + Kubernetes</p>
      </header>

      <main className="App-main">
        <div className="container">
          <section className="user-form">
            <h2>Add New User</h2>
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <input
                  type="text"
                  placeholder="Name"
                  value={newUser.name}
                  onChange={(e) => setNewUser({ ...newUser, name: e.target.value })}
                  required
                />
              </div>
              <div className="form-group">
                <input
                  type="email"
                  placeholder="Email"
                  value={newUser.email}
                  onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
                  required
                />
              </div>
              <button type="submit">Add User</button>
            </form>
          </section>

          <section className="user-list">
            <h2>Users</h2>
            {loading && <p>Loading...</p>}
            {error && <p className="error">{error}</p>}
            {users.length === 0 && !loading && <p>No users found</p>}
            {users.map(user => (
              <div key={user.id} className="user-card">
                <div className="user-info">
                  <h3>{user.name}</h3>
                  <p>{user.email}</p>
                  <small>ID: {user.id}</small>
                </div>
                <button 
                  onClick={() => handleDelete(user.id)}
                  className="delete-btn"
                >
                  Delete
                </button>
              </div>
            ))}
          </section>
        </div>
      </main>

      <footer className="App-footer">
        <p>Kubernetes Demo Application - Frontend</p>
      </footer>
    </div>
  );
}

export default App;
