import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

test('renders Kubernetes Demo title', () => {
  render(<App />);
  const titleElement = screen.getByText(/Kubernetes Demo - Frontend/i);
  expect(titleElement).toBeTruthy();
});

test('renders user form', () => {
  render(<App />);
  const formElement = screen.getByText(/Add New User/i);
  expect(formElement).toBeTruthy();
});

test('renders user list', () => {
  render(<App />);
  const listElement = screen.getByText(/Users/i);
  expect(listElement).toBeTruthy();
});
