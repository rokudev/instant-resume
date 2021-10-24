# Instant Resume

Instant Resume enables channels to save their current state upon exit and then continue playback upon relaunch. This improves the user experience by letting viewers quickly get back to the content they were watching without having to find it first. This sample demonstrates how to implement Instant Resume in a channel. It takes the completed [SceneGraph master sample channel](https://github.com/rokudev/scenegraph-master-sample), and does the following:

1. Updates the channel manifest with required attributes.

2. Implements the required suspend and resume handlers.

3. Adds signal beacons to measure channel suspend and resume times.

## Channel manifest

The last part of the channel manifest (lines 12 and 13) declare the `sdk_instant_resume=1` and `run_as_process=1` attributes. 

- **sdk_instant_resume=1**. Acknowledges that the channel has implemented all the requirements and protocols for the Instant Resume integration.

- **run_as_process=1**. Enables the Roku OS to preserve the channel state in the device RAM when the channel is suspended. 

## Suspend and resume handlers

The **videoPlayerLogic.brs** file includes `onMainSceneSuspend` and `onMainSceneResume` callback functions for when the channel is suspended and resumed from a channel exit, respectively. These callback functions are defined in the `MainScene.XML` component. 

- **onMainSceneSuspend**. When the channel is suspended after being exited, this callback function checks whether the channel was exited because the Home button was pressed on the Roku remote control. If the Home button was pressed and the viewer was watching content, they are returned to the Details sceen upon the relaunching the channel. The user can the resume playback or start watching from the beginning. 

- **onMainSceneResume**. When the channel is resumed, this callback function checks whether it recevied any launch parameters. If so, the channel [deeplinks](https://developer.roku.com/docs/developer-program/discovery/implementing-deep-linking.md#mediatype-behavior) into the content specified by the `contentId` using the launch behavior required by the specified `mediaType`.

## Signal beacons

The `onMainSceneResume` callback function in the **videoPlayerLogic.brs** file fires the **AppResumeComplete** beacon. This beacon must be fired when the suspended scene is fully rendered during the resume process and when video playback starts after handling a [deep link](https://developer.roku.com/docs/developer-program/discovery/implementing-deep-linking.md), once the channel can respond to commands sent via the Roku remote control.
