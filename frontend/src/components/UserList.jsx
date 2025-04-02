import React, { useState, useEffect } from 'react';
import axios from 'axios'; // Optional, if you want to use axios for the API call.

const UserList = () => {
  const [users, setUsers] = useState([]); // State to hold the user data
  const [loading, setLoading] = useState(true); // State to track loading state
  const [error, setError] = useState(null); // State to track any errors

  // Fetch users when the component mounts
  useEffect(() => {
    // API call to get users
    const fetchUsers = async () => {
      try {
        const response = await axios.get('/api/express/auth'); // Adjust this URL if needed
        setUsers(response.data.data); // Set user data to state
        setLoading(false); // Set loading to false once data is fetched
      } catch (error) {
        setError('Failed to fetch users');
        setLoading(false); // Set loading to false in case of error
      }
    };

    fetchUsers();
  }, []); // Empty dependency array means this will run only once after the component mounts

  // Display loading state or error if they exist
  if (loading) return <div>Loading...</div>;
  if (error) return <div>{error}</div>;

  return (
    <div>
      <h1>User List</h1>
      <table>
        <thead>
          <tr>
            <th>Username</th>
            <th>Address</th>
            <th>Phone</th>
            <th>Email</th>
            <th>Role</th>
          </tr>
        </thead>
        <tbody>
          {users.map((user) => (
            <tr key={user.username}>
              <td>{user.username}</td>
              <td>{user.address}</td>
              <td>{user.phone}</td>
              <td>{user.email}</td>
              <td>{user.role}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default UserList;
