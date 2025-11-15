# GatherEd: https://gathered-b4a8186deca9.herokuapp.com

Study Group Finder

## Team Members

-   Matthew Song
-   Daniel Wong
-   Ellis Mandel
-   Alex Anca

## MVP Description

A software platform for people taking the same class to propose or join a study group

## Details

Goal: Bridging the connection between people in the same class who want to study together
Users (students)

-   Propose study group time and location
-   Join study groups
-   Global chatting feature for the class

## Authentication & Google Login

GatherEd supports both traditional email/password authentication and Google sign-in.

1. Create a Google Cloud OAuth 2.0 Web application credential with callback `https://YOUR_DOMAIN/auth/google_oauth2/callback` (and `http://localhost:3000/auth/google_oauth2/callback` for local testing).
2. Copy `.env.example` to `.env` and paste your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.
3. When developing or using Docker (`docker compose up`), the `.env` file is automatically loaded so the credentials are available to Rails.
4. When deploying (Kamal, Render, etc.), set the same environment variables in your runtime configuration rather than committing secrets to the repo.

After configuring the environment variables, users will see a **Continue with Google** button on the login page that initiates OAuth flow and signs them in (creating an account if their email is new).
