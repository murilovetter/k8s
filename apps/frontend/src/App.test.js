import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

test('renders K8s Demo title', () => {
  render(<App />);
  const titleElement = screen.getByText(/K8s Demo/i);
  expect(titleElement).toBeInTheDocument();
});

test('renders user form', () => {
  render(<App />);
  const formElement = screen.getByText(/Add New User/i);
  expect(formElement).toBeInTheDocument();
});

test('renders user list', () => {
  render(<App />);
  const listElement = screen.getByText(/User List/i);
  expect(listElement).toBeInTheDocument();
});
