## Inspiration
**As Computer Science is a learning-intensive discipline, students tend to aspire to their professors**. We were inspired to hack this weekend by our beloved professor Daniel Zingaro (UTM). Answering questions in Dan's classes often ends up being a difficult part of our lectures, as Dan is visually impaired. This means students are expected to yell to get his attention when they have a question, directly interrupting the lecture. Teachers Pet could completely change the way Dan teaches and interacts with his students.

## What it does
Teacher's Pet (TP) empowers students and professors by making it easier to ask and answer questions in class. Our model helps to streamline lectures by allowing professors to efficiently target and destroy difficult and confusing areas in curriculum. Our module consists of an app, a server, and a camera. A professor, teacher, or presenter may download the TP app, and receive a push notification in the form of a discrete vibration whenever a student raises their hand for a question. This eliminates students feeling anxious for keeping their hands up, or professors receiving bad ratings for inadvertently neglecting students while focusing on teaching.

## How we built it
We utilized an Azure cognitive backend and had to manually train our AI model with over 300 images from around UofTHacks. Imagine four sleep-deprived kids running around a hackathon asking participants to "put your hands up". The AI is wrapped in a python interface, and takes input from a camera module. The camera module is hooked up to a Qualcomm dragonboard 410c, which hosts our python program. Upon registering, you may pair your smartphone to your TP device through our app, and set TP up in your classroom within seconds. Upon detecting a raised hand, TP will send a simple vibration to the phone in your pocket, allowing you to quickly answer a student query.

## Challenges we ran into
We had some trouble accurately differentiating when a student was stretching vs. actually raising their hand, so we took a sum of AI-guess-accuracies over 10 frames (250ms). This improved our AI success rate exponentially.

Another challenge we faced was installing the proper OS and drivers onto our Dragonboard. We had to "Learn2Google" all over again (for hours and hours). Luckily, we managed to get our board up and running, and our project was up and running!

## Accomplishments that we're proud of
We all are proud of each others commitment to the team. Nobody went to sleep while someone else was working. Teammates went on snack and coffee runs in freezing weather at 3AM. Everyone assisted on every aspect to some degree, and in the end, that fact likely contributed to our completion of TP. The biggest accomplishment that came from this was knowledge of various new APIs, and the gratification that came with building something to help our fellow students and professors.

## What we learned
Among the biggest lessons we took away was that **patience is key**. Over the weekend, we struggled to work with datasets as well as our hardware. Initially, we tried to perfect as much as possible and stressed over what we had left to accomplish in the timeframe of 36 hours. We soon understood, based on words of wisdom from our mentors, that _ the first prototype of anything is never perfect _. We made compromises, but made sure not to cut corners. We did what we had to do to build something we (and our peers) would love.


## What's next for Teachers Pet
We want to put this in our own classroom. This week, our team plans to sit with our faculty to discuss the benefits and feasibility of such a solution.
