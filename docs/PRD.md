# **GezAI: Product Requirements Document (MVP)**

## **1\. Project Overview**

**GezAI** is an AI-powered travel planning mobile app that generates personalized walking or driving routes for Turkish cities (starting with Üsküdar). It combines traditional category filtering with an LLM-powered natural language interface to visualize routes on an interactive map.

## **2\. Functional Requirements**

### **2.1 Route Generation & Personalization**

- **Input Mechanisms:**
  - **Quick-Toggle Categories:** Users can select/deselect categories (e.g., Mosques, Museums, Parks, Restaurants, Viewpoints).
  - **LLM Natural Language Prompt:** A free-text bar for specific requests (e.g., _"Show me the best sunset spots and a quiet cafe for reading"_).
- **Constraint Handling:** The system must consider the user's **current location**, **time of day** (opening/closing hours), and **selected transport mode** (Walking, Personal Car or Public Transit).
- **Regeneration ("Re-roll"):** Users can discard a suggested route and request a new version with one tap.

### **2.2 Route Intelligence (Time & Distance)**

- **Leg-by-Leg Estimates:** Every segment between Stop A and Stop B must display:
  - Travel duration (in minutes).
  - Distance (in meters or kilometers).
- **Stay Durations:** The AI suggests how long to spend at each location (e.g., 45 mins for a museum, 15 mins for a scenic viewpoint).
- **Total Trip Timeline:** A cumulative calculation showing the total time required for the entire route (Travel Time + Stay Time).

### **2.3 Interactive Mapping & Visualization**

- **Dynamic Polyline:** A visual path drawn on the map connecting all waypoints in the optimized order.
- **Place Detail Modals:** Interactive markers that, when tapped, show:
  - AI-curated historical context/brief info.
  - Current ratings and photos (via Google Places API).
  - "Why this was chosen" (Transparency logic).
- **Export Functionality:** Direct export of the optimized waypoint sequence to **Google Maps** for turn-by-turn navigation.

## **3\. Technical Specifications**

| **Component** | **Technology** | **Purpose** |
| --- | --- | --- |
| **Frontend** | **Flutter** | Cross-platform mobile UI. |
| --- | --- | --- |
| **Backend** | **Firebase** | User Auth, Firestore (Route storage), Cloud Functions. |
| --- | --- | --- |
| **AI/LLM** | **Gemini 2.5 Flash Lite** | Processing user intent and generating structured route JSON. |
| --- | --- | --- |
| **Maps Engine** | **Google Maps SDK** | Rendering the map and polylines. |
| --- | --- | --- |
| **Data Source** | **Google Places API** | Real-time place metadata, opening hours, and ratings. |
| --- | --- | --- |

## **4\. MVP Data & Logic Constraints**

- **Geofence:** Routes are restricted to the **Üsküdar District**.
- **Transport Modes:** Limited to **Walking**, **Personal Car or Public Transits (approx.)** (MVP ignores public ferry schedules).
- **Place Database:** A "Seed List" of the top 100 POIs in Üsküdar to minimize LLM hallucinations.

## **5\. User Interface (UI) Requirements**

- **The Timeline View:** A vertical list adjacent to the map showing the sequence of events (e.g., _10:00 AM: Start → 10:15 AM: Mosque A_).
- **Navigation Bridge:** A prominent "Start Route" button that deep-links into the user's preferred navigation app.
- **Profile/History:** A simple screen to access "Saved Routes."

## **6\. Success Metrics**

- **Route Accuracy:** Time estimates should be within a ±15% margin of reality.
- **User Retention:** Users returning to use the app for a second exploration in the same district.
- **Conversion:** Percentage of generated routes that are exported to Google Maps.