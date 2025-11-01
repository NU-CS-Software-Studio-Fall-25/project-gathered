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

## 🧰 Running the App Locally (with Docker)

### Prerequisites
- Docker & Docker Compose installed

### Steps
1. Build the images:
   docker compose build

2. Start the app:
   docker compose up

3. Access the app:
   http://localhost:3000

4. Stop the app:
   docker compose down

### Notes for Development
- The app mounts the current directory into the container (`.:/app`), so changes to files like CSS or views automatically appear.
- If assets are precompiled and you need to refresh them:
  docker compose run --rm web rails assets:clobber
  docker compose run --rm web rails assets:precompile