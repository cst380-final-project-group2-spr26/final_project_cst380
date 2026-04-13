# Mobile App Dev - App Brainstorming

===

## Step 1: Brainstormed App Ideas (All Group Members)

### Social / Fitness
1. **Sports Buddy Finder**  
   - A social platform to find local players for pickup games (basketball, soccer, tennis) based on skill level and location.

2. **Pickup Game Scheduler**  
   - Lets users schedule recurring weekly games and invite others nearby.

3. **Gym Partner Finder**  
   - Matches users with workout partners based on schedule and goals.

---

### Health & Fitness
4. **Lifting App (Smart Weight Tracker)**  
   - Tracks sets, reps, and one-rep max progress with built-in rest timers.

5. **Meal Prep Planner**  
   - Helps users plan weekly meals and generate grocery lists.

6. **Hydration Tracker**  
   - Reminds users to drink water and tracks daily intake.

---

### Travel / Lifestyle
7. **Hiking App (Trail Explorer)**  
   - Discover local hiking trails, upload photos, and rate trail conditions.

8. **Travel Budget Tracker**  
   - Helps users manage expenses while traveling.

9. **Local Events Finder**  
   - Shows concerts, events, and activities nearby.

---

### Education / Productivity
10. **Study Group Finder**  
   - Connects students in the same class for study sessions.

11. **Assignment Tracker**  
   - Organizes homework, deadlines, and reminders.

12. **Tutor Finder**  
   - Helps students find tutors based on subject and availability.

---

## Step 2: Top 3 App Ideas

1. **Sports Buddy Finder**  
2. **Lifting App (Smart Weight Tracker)**  
3. **Hiking App (Trail Explorer)**  

---

## Step 2.2: Evaluating App Ideas

### 1. Sports Buddy Finder
- **Mobile:** High. Uses Location/Maps and Push Notifications for real-time game updates.  
- **Story:** Compelling. Solves the problem of wanting to play sports without enough players.  
- **Market:** Large. Targets athletes, students, and casual players.  
- **Habit:** Medium/High. Users open it whenever they want to play sports.  
- **Scope:** Challenging but defined. Requires map view, game listings, and join functionality.  
- **API Availability:** Uses MapKit or Google Maps API, Firebase, and Push Notifications.  

---

### 2. Lifting App (Smart Weight Tracker)
- **Mobile:** Moderate. Useful for portability and quick gym logging.  
- **Story:** Clear value. Acts as a digital workout notebook.  
- **Market:** Huge. Targets gym-goers.  
- **Habit:** Very high. Used every workout session.  
- **Scope:** Well-formed. MVP includes logging exercises and viewing stats.  
- **API Availability:** Firebase for storage and authentication, local notifications.  

---

### 3. Hiking App (Trail Explorer)
- **Mobile:** Very high. Uses GPS, maps, and camera features.  
- **Story:** Compelling. Helps users find trails and real-time conditions.  
- **Market:** Niche but clear. Targets hikers.  
- **Habit:** Moderate. Mostly weekend usage.  
- **Scope:** Broad but manageable. MVP includes map + reviews.  
- **API Availability:** MapKit/Google Maps API, Firebase, optional weather APIs.  

---

## Step 2.3: Final Decision

### Final Project Idea: **Sports Buddy Finder**

---

## User Stories (Minimum Viable Product)

- As a user, I want to view a map of nearby pickup games so I can find a place to play.  
- As a user, I want to create a game lobby with a sport, time, and skill level.  
- As a user, I want to join an existing game so the host knows I’m coming.  
- As a user, I want to receive notifications when a game is about to start.  

---

## App Evaluation (Final Idea)

- **Mobile:** Essential. Uses GPS and notifications.  
- **Story:** Strong. Solves the “no one to play with” problem.  
- **Market:** Large.  
- **Habit:** High.  
- **Scope:** Defined.  
  - V1: Map/List + Create/Join  
  - V2: Chat + Ratings  

---

## Technical Plan (APIs / Tools)

- **MapKit (iOS) / Google Maps API**  
- **Firebase**  
- **Push Notifications (Apple Push Notifications / FCM)**  
