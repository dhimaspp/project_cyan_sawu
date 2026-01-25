# Spec: Navigation

## Overview
Navigation capability defines how users move between screens based on authentication state, with support for session persistence and logout.

## ADDED Requirements

### Requirement: Auth-Based Root Navigation
The app SHALL display different screens based on authentication state.

#### Scenario: User is not authenticated
- **Given** the user has not signed in
- **When** the app launches
- **Then** the LoginPage is displayed

#### Scenario: User is authenticated
- **Given** the user has successfully signed in
- **When** the app launches or auth state changes
- **Then** the HomePage is displayed
- **And** the user's email is shown on the page

#### Scenario: User signs out
- **Given** the user is on HomePage
- **When** the user taps sign out and confirms
- **Then** the user is navigated to LoginPage

---

### Requirement: Session Persistence
The app SHALL persist the user's session so they don't need to re-login on every app launch.

#### Scenario: User reopens app after login
- **Given** the user has previously signed in
- **And** the user closes the app
- **When** the user reopens the app
- **Then** the HomePage is displayed directly
- **And** the user does NOT see the LoginPage

#### Scenario: User reopens app after logout
- **Given** the user has previously signed out
- **When** the user reopens the app
- **Then** the LoginPage is displayed

---

### Requirement: Logout with Confirmation
The app SHALL require confirmation before signing the user out.

#### Scenario: User initiates logout
- **Given** the user is on HomePage
- **When** the user taps the logout button
- **Then** a confirmation dialog is displayed

#### Scenario: User confirms logout
- **Given** the confirmation dialog is displayed
- **When** the user confirms
- **Then** the user is signed out
- **And** the LoginPage is displayed

#### Scenario: User cancels logout
- **Given** the confirmation dialog is displayed
- **When** the user cancels
- **Then** the dialog closes
- **And** the user remains on HomePage

---

### Requirement: Camera Navigation
The app SHALL provide navigation from HomePage to CameraPage.

#### Scenario: User wants to capture a report
- **Given** the user is on HomePage
- **When** the user taps "Capture Report"
- **Then** the CameraPage is opened
- **And** the camera preview is displayed

#### Scenario: User closes camera
- **Given** the user is on CameraPage
- **When** the user taps close/back
- **Then** the user returns to HomePage

## Cross-References
- See: `secure-camera` capability for camera requirements
- See: Phase 1 `authentication` capability for auth requirements
