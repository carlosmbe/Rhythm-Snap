
# Rhythm Snap


A brief description of what this project does and who it's for:

My Playground uses the iPad’s Camera, Vision, and other frameworks to provide users with an immersive way to practise their rhythm skills.

To begin with, I developed a BPM Tracker, which is an integral part of the rhythm practice experience that offers users real-time feedback on their performance. The BPM Tracker is responsible for the metronome and providing feedback. As users tap their fingers or press a button in sync with the beats, it evaluates their timing accuracy by comparing their taps to the pre-set tempo, in this case 1⁄2 Beats at 95 BPM. The app then offers immediate feedback such as "Good Timing" or "Needs some work," helping users improve their sense of rhythm while maintaining engagement.

In addition, I incorporated Apple's Vision framework for the detection and analysis of the user’s hand gestures in real-time. While the BPM Tracker focuses on the timing of the user's taps, the Vision framework enhances the experience by processing the live camera feed to recognize hand poses and determine the state of the user's hand. Specifically, the app focuses on the contact between the thumb and middle fingertips as the user taps in sync with the beats of either the metronome or song. This integration of the camera and Vision offers a new way for users to practise that’s more engaging than simply pressing a button.

Furthermore, I utilised SwiftUI for most of the app’s User Interface, with some UI Kit for the Camera’s Viewfinder. A standout feature of the UI is the dynamic waveform that visualises the song in real-time, rather than being pre-rendered. The responsive layout adapts to different screen sizes and displays the audio waves as a series of bars with gradient colours. The height of these bars changes based on the audio's volume at any given moment, creating an appealing visual representation of the audio.

# Beautiful Pictures (Screenshots)

![IMG_0226](https://github.com/carlosmbe/Rhythm-Snap/assets/53784701/a6e71aa7-a10e-4913-8c78-e12a9a2cf1a8)

![IMG_0227](https://github.com/carlosmbe/Rhythm-Snap/assets/53784701/74438c96-0255-4dba-8607-81185cc6733b)


![IMG_0230](https://github.com/carlosmbe/Rhythm-Snap/assets/53784701/e98dae70-3f5e-40fc-87ee-7934f57e19a4)
