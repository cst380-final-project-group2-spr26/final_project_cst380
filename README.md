# final_project_cst380

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

Sports Buddy Finder is a social networking app designed to bridge the gap between solo athletes and local pickup games. Whether you're looking for people for a soccer match or a full squad for a basketball run, this app allows users to find, host, and join local sporting events in real-time based on location and skill level.

### App Evaluation

- **Category:** Social / Fitness
- **Mobile:** Mobile is essential for real-time GPS location tracking to find nearby games and for push notifications to alert users of upcoming game starts or new joins.
- **Story:** the common "empty court" problem by connecting people who want to stay active but lack a consistent group of players.
- **Market:** Large and diverse, ranging from college students looking for intramural games to adults seeking weekend recreational sports.
- **Habit:** High frequency; users engage whenever they feel like exercising or checking for game availability in their area.
- **Scope:** Clearly defined. The MVP focuses on game discovery and creation, while later versions can expand into in-app messaging and skill-based matchmaking.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- User can register a new account and log in.
- User can view a Map/List of nearby pickup games.
- User can create a new game lobby (specifying sport, time, location, and difficulty).
- User can "Join" a game lobby to notify the host.
- User can view their profile and a list of games they are attending.

**Optional Nice-to-have Stories**

- User can chat with other participants in a specific game lobby.
- User can rate other players' skill levels or sportsmanship.
- User receives a push notification 30 minutes before a game starts.

### 2. Screen Archetypes

- Login / Register Screen
- User can sign up or log in to their account.
- Map View (Home)
- User can see pins of nearby games and filter by sport.
- Stream/List View
- User can scroll through a list of upcoming games sorted by time or proximity.
- Creation Screen
- User can fill out a form to host a new game.
- Detail View
- User can see specific game details (who is playing, exact location, rules).
- Profile Screen
- User can see their stats, bio, and history of games played.

### 3. Navigation

- Tab Navigation (Tab to Screen)
- Map: Browse games geographically.
- List: Browse games chronologically.
- Create: Host a new game.
- Profile: Manage user settings and history.
  
**Flow Navigation** (Screen to Screen)
- Map/List View * Leads to Detail View when a game is selected.
- Detail View
- Leads back to Map/List or stays on page after "Join" is clicked.
- Creation Screen
- Leads to Map/List after the game is successfully posted.

- ## Wireframes

Here's the wireframe handwritten diagram:
![Wireframe](https://github.com/cst380-final-project-group2-spr26/final_project_cst380/raw/adding-diagram/wireframe.png)

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 


### Models

[Model Name, e.g., User]
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| username | String | unique id for the user post (default field)   |
| password | String | user's password for login authentication      |
| ...      | ...    | ...                          


### Networking

- [List of network requests by screen]
- [Example: `[GET] /users` - to retrieve user data]
- ...
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
