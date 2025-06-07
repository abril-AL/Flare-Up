# Flareup Final Blog
### Project Motivations
The origin of `flareup` came as a means to tackle issues of self-learning technology and the current problems with the state of self-learning among individuals. When thinking through our project and conducting user interviews, our group realize the core problem was not necessarily related to the current self-learning innovations— the core problem of self-learning is rooted in productivity.

`flareup` is motivated by users such as college students & independent workers who deeply value accountability in order to stay productive. As a team, we hope to mitigate issues relevant to holding deep focus when working. Additionally, we want to reduce the average screentime among users of our application, which we aim to do so with a gameified productivity experience.

### Problem Statement
> *All b\*tches wanna do is scroll on their phone, have ADHD, be bisexual, eat hot chip, and lie (about locking in)*

> Many individuals struggle to sustain focused work due to distracting habits & a lack of accountability. 

> Existing screen time tools are private & passive, so they don’t tap into the motivating power of peer accountability or friendly competition.
### User research

Before user research was focused on screen time and accountability, our team was focused on self-learning and modularization. These interviews revealed an underlying issue for learning, attention and distractions. 

In our initial user research, we asked about student's learning experiences, but a lot guidance was needed to push them to answer in meaningfully / insightful ways. To dig deeper, beyond their generic answers, we reworked our questions, but ultimately the focus topic was the issue. 

Self-learning was too broad of a problem for one system to solve. We were struggling to solidify a direction based on user research. But, through this first round of research we uncovered a consistent theme: students across the board expressed frustration with their inability to stay productive and avoid distractions—especially those related to phone use. All users admitted to wanting to reduce their screen time but felt it was nearly impossible. This insight led us to pivot toward the theme of productivity, specifically focusing on screen time habits. We launched a follow-up survey to pinpoint the specific areas users struggle with, and began exploring early solutions such as social screen time sharing or app restriction modes.

We continued to conduct user research after in order to delve into this issue in depth. While the survey helped us reach a broad audience quickly, it lacked the depth needed to fully understand students’ specific needs and motivations. 

As a result, it was unclear how effective our idea would be in real-life contexts. Moving forward, we aim to test our proposed features more directly and gather more personal, detailed feedback. 
### Design goals, incorporating instructor feedback
We created the following personas to keep i mind as we designed out system:

**Persona 1: David**
- **Background**: UCLA senior, 22 years old, Computer Science major, lives off-campus
- **Goals**: Finish assignments on time
- **Pain Points**:
	* Frequently doom-scrolls on social media
	* Has ADHD and struggles with focus
	* Feels guilty about wasted time
	* Easily distracted and finds it hard to study at home due to lack of accountability

**Persona 2: Maria**
- **Background**: Harvard freshman, 18 years old, Psychology major, lives in a dorm
- **Goals**:
	* Build strong study habits early
	* Find structure and study partners
- **Pain Points**:
	* Gets distracted easily
	* Doesn’t yet have friends on campus
	* Struggles to trust her own time management

**Persona 3: Rina**
- **Background**: 26 years old, freelance graphic designer, works from coffee shops
- **Goals**:
	* Deliver client drafts on time
	* Find community-driven accountability
- **Pain Points**:
	* Overspends on coffee just to access a work environment
	* Gets sidetracked by chats and emails
	* Lacks fixed deadlines and structure

We defined the following design goals as well:

1. **Creating an engaging interface that gamifies the reduction of screen time while not overwhelming the user.**
	1. We want to make reducing screen time “fun” for users and social. However, we don’t want to overstimulate the user with an excessive amount of different colors, different features, and different graphics. In our prototype, we got a comment about the colors being too bright. Having a clear color palette that is cohesive and easy to the eye. We want to make sure that the aesthetics of the application convey a certain theme/message. 
2. **Creating incentives for the user to keep using the application + Targeting user’s competitiveness**
	1. Current screentime applications are often focused on displaying information to the individual. However, we realized that individuals get desensitized to their own screen time, so we want to implement a social aspect where people would be held accountable by displaying/publicizing their screen time. In addition, from our user research, we found that DuoLingo’s streak system helped people stay motivated. We want to create a visual incentive like a streak system to incentivize users. Having a clear color palette that is cohesive and easy to the eye. We want to make sure that the aesthetics of the application convey a certain theme/message. Giving little “dopamine snacks” in our user experience

Throughout the design process we also received instructor feedback. 

After our crit presentations, they appreciated the emotional insight in the problem, specially users' disappointment in themselves and the need for community-driven accountability. Maria’s persona stood out as compelling, unique, and realistic, especially for highlighting social isolation. The wager and flare features were praised for promoting motivation and connection, with a suggestion to expand flares as a tool for newcomers to connect around shared classes. 

Later, they also recommended being intentional with feature scope—focusing on either flares or wagers as the primary gamification mechanic to avoid overwhelming users. Then they suggested structuring the development timeline around individual features rather than separating backend and frontend phases to prioritize core interactions early.

### System design and implementation 
#### Paper Prototype

Our initial prototype included our core features: flares, groups, and wagers. Our goal was to display a user's individual screen time data, interact with friends by forming groups. Groups allow users to view weekly recaps and set weekly wagers. Flares are essentially a ping users send out to their friends to indicate they were looking for a body double or study buddy. 

From an in class discussion, we discovered that users were confused by navigating between multiple friends / groups pages and unclear on how to leave or delete groups. On the profile page, users expected more interactive or detailed information, especially for streaks and trophies. Term like "next drop" were also not understood without asking, and users suggested an onboarding walkthrough to clarify app terminology. Lastly, users wanted mode tappable  analytics throughout, especially in sections like "Your Data" ot "Top Apps."

This feed back helped us expand from these few screens into out more detailed Figma prototype...

#### Figma Prototype
Main 
- includes our loading, login, and sign up pages

![image](https://github.com/user-attachments/assets/8a6d3b05-2a65-4580-aca2-cacddbaebe2e)

Home 
- What the user first sees after signing in 
- Protopype for a opening guide for new users

![image](https://github.com/user-attachments/assets/8bef0db5-69a4-45ed-8ef0-9f1daac272e6)

Profile
- Profile page displays a personal weekly summary, streak information, screentime log functionality, and current user status
- The edit button allows users to change their display name / username, status, and screen time goal
- The screentime log button brings user to the "Drop Report" page to insert their times and most used app

![image](https://github.com/user-attachments/assets/007ceac2-300a-49dc-bebc-f143b8640a70)

Friends
- Main friends page displays subset of all friends (sidescroll), with the option to see all on another page
- Groups that the user are in are then listed underneath, with the option to add groups
- Group pages list a group drop (screen time summary per group), last wager loser and their wager and screen time, and a screen time leaderboard
- Page with all friends has the option to flare individuals, and send/recieve friend requests
- Adding friends is done per username

![image](https://github.com/user-attachments/assets/cf195a29-fce8-4c37-9757-21af35727c12)

Flares
- Flares page allows user to view incoming and outgoing flares
- Summarizes flare information for the user: sent/recieved and top senders/recievers
- Incoming flares: view status and message sent by users
- Outgoing flares: send flares to selected users with a note and status  

![image](https://github.com/user-attachments/assets/faa5b440-0391-4f49-8ad7-f79d4289c38a)


#### Frontend Implementation  

### Evaluation question, methods, and analysis approach


### Findings


### Discussion of your takeaways based on the evaluation, limitations and future work, mistakes and lessons learned


### What new questions do you have based on your evaluation? 


### At least 2 figures, including one of your system!
