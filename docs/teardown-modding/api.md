<!-- source: https://teardowngame.com/modding/api.html -->

# Teardown scripting API (2.0.2)

## Teardown scripting

Teardown uses Lua version 5.1 as scripting language. The Lua 5.1 reference manual can be found [here](<https://www.lua.org/manual/5.1/>). Each Teardown script runs in its own Lua context and can only interact with the engine and other scripts through API functions and the registry. The registry is a database of hierarchical global variables that is used both internally in the engine, for communication between scripts and as a way to save persistent data. 

The Teardown API uses only native lua types. Handles to objects are plain Lua numbers. Vector types are represented as plain Lua tables, and so on. 

Starting with version 2.0, the Teardown API supports networked multiplayer using a client/server architecture. The same script runs both on the server and on each client, but different parts of the script are used. This is implemented through the server and client tables. Teardown does not use dedicated servers, so the player hosting a session will be the server for that session while also acting as one of the clients. Hence, the host is both the server and one of the clients, while everyone else is just a client. 

 Built in table |  Description  
---|---  
server |  Only exists on the server. You can put your own global variables in here, but they will only be available on the server.  
client |  This is similar to the server table, but only exists on clients.  
shared |  Automatically synchronized data from server to client parts of the same script. Read-only from the client part of the script. The server can put any data type in the shared table, including tables, but having a lot of data that changes often can consume a lot of bandwith.  
  
Each script has the following server callback functions that will be called by the game engine. Note that all of them are optional. In many cases, you will only need the init and tick. Most of the game logic should be implemented on the server. 

 Server function |  Description  
---|---  
function server.init() |  Called once at load time  
function server.tick(dt) |  Called exactly once per frame. The time step is variable but always between 0.0 and 0.0333333  
function server.update(dt) |  Called at a fixed update rate, but at the most two times per frame. Time step is always 0.0166667 (60 updates per second). Depending on frame rate it might not be called at all for a particular frame.  
function server.postUpdate()  |  Called like update, but after physics. Because update can trigger physics updates, it can be necessary to do some additional calculations afterwards.  
function server.destroy()  |  For game mode scripts, this is called when the game mode is stopped  
  
The following optional callback functions are available on the client. The client part of a script is typically used for overlay graphics and user interfaces, but it can also be used for optimization purposes to spawn local particle effects, sounds or animations. 

 Client function |  Description  
---|---  
function client.init() |  Called once at load time  
function client.tick(dt) |  Called exactly once per frame. The time step is variable but always between 0.0 and 0.0333333  
function client.update(dt) |  Called at a fixed update rate, but at the most two times per frame. Time step is always 0.0166667 (60 updates per second). Depending on frame rate it might not be called at all for a particular frame.  
function client.postUpdate()  |  Called like update, but after physics. Because update can trigger physics updates, it can be necessary to do some additional calculations afterwards. This is usually used by animators.  
function client.draw() |  Called when the 2D overlay is being draw, after the scene but before the standard HUD. Ui functions can only be used from this callback.  
function client.render(dt) |  Called exactly once per frame, right before things are actually drawn to the screen.  
function client.destroy()  |  For game mode scripts, this is called when the game mode is stopped  
  
* * *

## Parameters

Scripts can have parameters defined in the level XML file. These serve as input to a specific instance of the script and can be used to configure various options and parameters of the script. While these parameters can be read at any time in the script, it's recommended to copy them to a global variable in or outside the init function. 

GetIntParam GetFloatParam GetBoolParam GetStringParam GetColorParam

* * *

## Script control

General functions that control the operation and flow of the script.  Physical input |  Description  
---|---  
esc |  Escape key  
tab |  Tab key  
lmb |  Left mouse button  
rmb |  Right mouse button  
mmb |  Middle mouse button  
uparrow |  Up arrow key  
downarrow |  Down arrow key  
leftarrow |  Left arrow key  
rightarrow |  Right arrow key  
f1-f12 |  Function keys  
backspace |  Backspace key  
alt |  Alt key  
delete |  Delete key  
home |  Home key  
end |  End key  
pgup |  Pgup key  
pgdown |  Pgdown key  
insert |  Insert key  
space |  Space bar  
shift |  Shift key  
ctrl |  Ctrl key  
return |  Return key  
any |  Any key or button  
a,b,c,... |  Latin, alphabetical keys a through z  
0-9 |  Digits, zero to nine  
mousedx |  Mouse horizontal diff. Only valid in InputValue.  
mousedy |  Mouse vertical diff. Only valid in InputValue.  
mousewheel |  Mouse wheel. Only valid in InputValue.  
  
 Logical input |  Description  
---|---  
up |  Move forward / Accelerate  
down |  Move backward / Brake  
left |  Move left  
right |  Move right  
interact |  Interact  
flashlight |  Flashlight  
jump |  Jump  
crouch |  Crouch  
usetool |  Use tool  
grab |  Grab  
handbrake |  Handbrake  
map |  Map  
pause |  Pause game (escape)  
vehicleraise |  Raise vehicle parts  
vehiclelower |  Lower vehicle parts  
vehicleaction |  Vehicle action  
camerax |  Camera x movement, scaled by sensitivity. Only valid in InputValue.  
cameray |  Camera y movement, scaled by sensitivity. Only valid in InputValue.  
tool_group_prev |  Switch to previous tool group  
tool_group_next |  Switch to next tool group  
extra0 |  Extra action 0  
extra1 |  Extra action 1  
extra2 |  Extra action 2  
extra3 |  Extra action 3  
extra4 |  Extra action 4  
extra5 |  Extra action 5  
extra6 |  Extra action 6  
photomode |  Photomode  
zoom |  Zoom  
menu_left |  Menu left  
menu_right |  Menu right  
menu_up |  Menu up  
menu_down |  Menu down  
menu_next |  Menu next  
menu_prev |  Menu prev  
menu_accept |  Menu accept  
menu_cancel |  Menu cancel  
  
GetVersion HasVersion GetTime GetTimeStep InputLastPressedKey InputPressed InputReleased InputDown InputValue InputClear InputResetOnTransition LastInputDevice SetValue SetValueInTable PauseMenuButton HasFile StartLevel SetPaused Restart Menu ClientCall ServerCall

* * *

## Registry

The Teardown engine uses a global key/value-pair registry that scripts can read and write. The engine exposes a lot of internal information through the registry, but it can also be used as way for scripts to communicate with each other. 

The registry is a hierarchical node structure and can store a value in each node (parent nodes can also have a value). The values can be of type floating point number, integer, boolean or string, but all types are automatically converted if another type is requested. Some registry nodes are reserved and used for special purposes. 

Registry node names may only contain the characters a-z, numbers 0-9, dot, dash and underscore. 

 Key |  Description  
---|---  
options |  reserved for game settings (write protected from mods)  
game |  reserved for the game engine internals (see documentation)  
savegame |  used for persistent game data (write protected for mods)  
savegame.mod |  used for persistent mod data. Use only alphanumeric character for key name.  
level |  not reserved, but recommended for level specific entries and script communication  
  
ClearKey ListKeys HasKey SetInt GetInt SetFloat GetFloat SetBool GetBool SetString GetString SetColor GetColor GetTranslatedStringByKey HasTranslationByKey LoadLanguageTable GetUserNickname

* * *

## Events

The event system allows scripts to register listeners for events and trigger them. Events are used to communicate between scripts. 

Events can also be triggered by the game engine, such as player death, explosion, etc. The following built-in events are available:  Event |  Description |  Parameters |  Availability  
---|---|---|---  
playerhurt  |  Triggered when a player is hurt. |  playerId (number), healthBefore (number), healthAfter (number), attackerId (number), point (TVec), impulse (TVec) |  Server and Client  
playerdied  |  Triggered when a player dies. |  playerId (number), attackerId (number), damage (number), healthBefore (number), cause (string), point (TVec), impulse (TVec) |  Server and Client  
explosion  |  Triggered when an explosion occurs. |  point (TVec), strength (number) |  Server only  
projectilehit  |  Triggered when a projectile hits an object. |  shape (number), point (TVec), direction (TVec) |  Server only  
  
You can also create custom events that can be triggered by your scripts and listened to by other scripts. 

GetEventCount PostEvent GetEvent

* * *

## Vector math

Vector math is used in Teardown scripts to represent 3D positions, directions, rotations and transforms. The base types are vectors, quaternions and transforms. Vectors and quaternions are indexed tables with three and four components. Transforms are tables consisting of one vector (pos) and one quaternion (rot) 

Vec VecCopy VecStr VecLength VecNormalize VecScale VecAdd VecSub VecDot VecCross VecLerp Quat QuatCopy QuatAxisAngle QuatDeltaNormals QuatDeltaVectors QuatEuler QuatAlignXZ GetQuatEuler QuatLookAt QuatSlerp QuatStr QuatRotateQuat QuatRotateVec Transform TransformCopy TransformStr TransformToParentTransform TransformToLocalTransform TransformToParentVec TransformToLocalVec TransformToParentPoint TransformToLocalPoint SetRandomSeed GetRandomBool GetRandomInt GetRandomFloat GetRandomDirection

* * *

## Entity

An Entity is the basis of most objects in the Teardown engine (bodies, shapes, lights, locations, etc). All entities can have tags, which is a way to store custom properties on entities for scripting purposes. Some tags are also reserved for engine use. See documentation for details. 

FindEntity FindEntities GetEntityChildren GetEntityParent SetTag RemoveTag HasTag GetTagValue ListTags GetDescription SetDescription Delete IsHandleValid GetEntityType GetProperty SetProperty

* * *

## Body

A body represents a rigid body in the scene. It can be either static or dynamic. Only dynamic bodies are affected by physics. 

FindBody FindBodies GetBodyTransform SetBodyTransform GetBodyMass IsBodyDynamic SetBodyDynamic SetBodyVelocity GetBodyVelocity GetBodyVelocityAtPos SetBodyAngularVelocity GetBodyAngularVelocity IsBodyActive SetBodyActive ApplyBodyImpulse GetBodyShapes GetBodyVehicle GetBodyAnimator GetBodyPlayer GetBodyBounds GetBodyCenterOfMass IsBodyVisible IsBodyBroken IsBodyJointedToStatic DrawBodyOutline DrawBodyHighlight GetBodyClosestPoint ConstrainVelocity ConstrainAngularVelocity ConstrainPosition ConstrainOrientation GetWorldBody

* * *

## Shape

A shape is a voxel object and always owned by a body. A single body may contain multiple shapes. The transform of shape is expressed in the parent body coordinate system. 

FindShape FindShapes GetShapeLocalTransform SetShapeLocalTransform GetShapeWorldTransform GetShapeBody GetShapeJoints GetShapeLights GetShapeBounds SetShapeEmissiveScale SetShapeDensity GetShapeMaterialAtPosition GetShapeMaterialAtIndex GetShapeSize GetShapeVoxelCount IsShapeVisible IsShapeBroken DrawShapeOutline DrawShapeHighlight SetShapeCollisionFilter GetShapeCollisionFilter CreateShape ClearShape ResizeShape SetShapeBody CopyShapeContent CopyShapePalette GetShapePalette GetShapeMaterial SetBrush DrawShapeLine DrawShapeBox ExtrudeShape TrimShape SplitShape MergeShape IsShapeDisconnected IsStaticShapeDetached GetShapeClosestPoint IsShapeTouching

* * *

## Location

Locations are transforms placed in the editor as markers. Location transforms are always expressed in world space coordinates. 

FindLocation FindLocations GetLocationTransform

* * *

## Joint

Joints are used to physically connect two shapes. There are several types of joints and they are typically placed in the editor. When destruction occurs, joints may be transferred to new shapes, detached or completely disabled. 

FindJoint FindJoints IsJointBroken GetJointType GetJointOtherShape GetJointShapes SetJointMotor SetJointMotorTarget GetJointLimits GetJointMovement GetJointedBodies DetachJointFromShape GetRopeNumberOfPoints GetRopePointPosition GetRopeBounds BreakRope

* * *

## Animation

An animator manages a prefab hierarchy using a matching skeleton and a set of animation sequences. These animations are processed sequentially, generating a "blend-tree." 

There are two types of animations: looping and single-shot. Looping animations must be called every frame to keep them active; otherwise, they will stop. In contrast, single-shot animations are triggered once and will play to completion. 

Single-shot animations are automatically processed after all looping animations, but they can be executed earlier if necessary. To ensure that single-shot animations are processed in the correct order within the blend-tree, an instance API is available. 

Inverse Kinematics (IK) can be used, typically as the final step, to control specific parts of the skeleton, such as reaching for an object. 

SetAnimatorPositionIK SetAnimatorTransformIK GetBoneChainLength FindAnimator FindAnimators GetAnimatorTransform GetAnimatorAdjustTransformIK SetAnimatorTransform MakeRagdoll UnRagdoll PlayAnimation PlayAnimationLoop PlayAnimationInstance StopAnimationInstance PlayAnimationFrame BeginAnimationGroup EndAnimationGroup PlayAnimationInstances GetAnimationClipNames GetAnimationClipDuration SetAnimationClipFade SetAnimationClipSpeed TrimAnimationClip GetAnimationClipLoopPosition GetAnimationInstancePosition SetAnimationClipLoopPosition SetBoneRotation SetBoneLookAt RotateBone GetBoneNames GetBoneBody GetBoneWorldTransform GetBoneBindPoseTransform

* * *

## Light

Light sources can be of several differnt types and configured in the editor. If a light source is owned by a shape, the intensity of the light source is scaled by the emissive scale of that shape. If the parent shape breaks, the emissive scale is set to zero and the light source is disabled. A light source without a parent shape will always emit light, unless exlicitly disabled by a script. 

FindLight FindLights SetLightEnabled SetLightColor SetLightIntensity GetLightTransform GetLightShape IsLightActive IsPointAffectedByLight GetFlashlight SetFlashlight

* * *

## Trigger

Triggers can be placed in the scene and queried by scripts to see if something is within a certain part of the scene. 

FindTrigger FindTriggers GetTriggerTransform SetTriggerTransform GetTriggerBounds IsBodyInTrigger IsVehicleInTrigger IsShapeInTrigger IsPointInTrigger IsPointInBoundaries IsTriggerEmpty GetTriggerDistance GetTriggerClosestPoint

* * *

## Screen

Screens display the content of UI scripts and can be made interactive. 

FindScreen FindScreens SetScreenEnabled IsScreenEnabled GetScreenShape GetScreenPlayer

* * *

## Vehicle

Vehicles are set up in the editor and consists of multiple parts owned by a vehicle entity. 

FindVehicle FindVehicles GetVehicleTransform GetVehicleExhaustTransforms GetVehicleVitalTransforms GetVehicleBodies GetVehicleBody GetVehicleHealth GetVehicleParams SetVehicleParam GetVehicleDriverPos GetVehicleAvailableSeatPos GetVehicleSteering GetVehicleDrive DriveVehicle GetVehicleLocationWorldTransform GetVehiclePassengerCount SetVehicleHealth

* * *

## Rig

Rig functions. A rig contains a set of named transforms often used by the player script to set IK-targets, but it can be used as a general transform container as well. Transforms are stored internally as local transforms relative the rig transform. A rig can itself be a child to a body(using "relative_parent" tag) or vehicle(automatically relative to vehicle) 

FindRig GetRigWorldTransform SetRigWorldTransform GetRigLocationWorldTransform SetRigLocationWorldTransform GetRigLocationLocalTransform SetRigLocationLocalTransform

* * *

## Player

The player functions expose certain information about the player. 

GetAllPlayers GetMaxPlayers GetPlayerCount GetAddedPlayers GetRemovedPlayers GetPlayerName GetLocalPlayer IsPlayerLocal GetPlayerCharacter IsPlayerHost IsPlayerValid GetPlayerPos GetPlayerAimInfo GetPlayerPitch GetPlayerYaw SetPlayerPitch GetPlayerCrouch GetPlayerTransform GetPlayerTransformWithPitch SetPlayerTransform SetPlayerTransformWithPitch SetPlayerGroundVelocity GetPlayerEyeTransform GetPlayerCameraTransform SetPlayerCameraOffsetTransform SetPlayerSpawnTransform SetPlayerSpawnHealth SetPlayerSpawnTool GetPlayerVelocity SetPlayerVehicle SetPlayerAnimator GetPlayerAnimator GetPlayerBodies SetPlayerVelocity GetPlayerVehicle IsPlayerGrounded IsPlayerVehicleDriver IsPlayerVehiclePassenger IsPlayerJumping GetPlayerGroundContact GetPlayerGrabShape GetPlayerGrabBody ReleasePlayerGrab GetPlayerGrabPoint GetPlayerPickShape GetPlayerPickBody GetPlayerInteractShape GetPlayerInteractBody SetPlayerScreen GetPlayerScreen SetPlayerHealth GetPlayerHealth GetPlayerCanUseTool SetPlayerRegenerationState SetPlayerTool GetPlayerTool RespawnPlayer RespawnPlayerAtTransform GetPlayerWalkingSpeed SetPlayerWalkingSpeed GetPlayerCrouchSpeedScale SetPlayerCrouchSpeedScale GetPlayerHurtSpeedScale SetPlayerHurtSpeedScale GetPlayerParam SetPlayerParam SetPlayerHidden RegisterTool SetToolAmmoPickupAmount GetToolAmmoPickupAmount GetToolBody GetToolHandPoseLocalTransform GetToolHandPoseWorldTransform SetToolHandPoseLocalTransform GetToolLocationLocalTransform GetToolLocationWorldTransform SetToolTransform SetToolAllowedZoom SetToolTransformOverride SetToolOffset SetToolAmmo GetToolAmmo SetToolEnabled IsToolEnabled SetPlayerOrientation GetPlayerOrientation GetPlayerUp SetPlayerRig GetPlayerRig GetPlayerRigWorldTransform ClearPlayerRig SetPlayerRigLocationLocalTransform SetPlayerRigTransform GetPlayerRigLocationWorldTransform SetPlayerRigTags GetPlayerRigHasTag GetPlayerRigTagValue GetPlayerColor SetPlayerColor ApplyPlayerDamage DisablePlayerInput DisablePlayer IsPlayerDisabled DisablePlayerDamage

* * *

## Sound

Sound functions are used for playing sounds or loops in the world. There sound functions are always positioned and will be affected by acoustics simulation. If you want to play dry sounds without acoustics you should use UiSound and UiSoundLoop in the User Interface section. 

LoadSound UnloadSound LoadLoop UnloadLoop SetSoundLoopUser PlaySound PlaySoundForUser StopSound IsSoundPlaying GetSoundProgress SetSoundProgress PlayLoop GetSoundLoopProgress SetSoundLoopProgress PlayMusic StopMusic IsMusicPlaying SetMusicPaused GetMusicProgress SetMusicProgress SetMusicVolume SetMusicLowPass

* * *

## Sprite

Sprites are 2D images in PNG or JPG format that can be drawn into the world. Sprites can be drawn with ot without depth test (occluded by geometry). Sprites will not be affected by lighting but they will go through post processing. If you want to display positioned information to the player as an overlay, you probably want to use the Ui functions in combination with UiWorldToPixel instead. 

LoadSprite DrawSprite

* * *

## Scene queries

Query the level in various ways. 

QueryRequire QueryInclude QueryCollisionMask QueryRejectAnimator QueryRejectVehicle QueryRejectBody QueryRejectBodies QueryRejectShape QueryRejectShapes QueryRejectPlayer QueryRaycast QueryRaycastRope QueryRaycastWater QueryShot QueryClosestPoint QueryAabbShapes QueryAabbBodies QueryPath CreatePathPlanner DeletePathPlanner PathPlannerQuery AbortPath GetPathState GetPathLength GetPathPoint GetLastSound IsPointInWater GetWindVelocity

* * *

## Particles

Functions to configure and emit particles, used for fire, smoke and other visual effects. There are two types of particles in Teardown - plain particles and smoke particles. Plain particles are simple billboard particles simulated with gravity and velocity that can be used for fire, debris, rain, snow and such. Smoke particles are only intended for smoke and they are simulated with fluid dynamics internally and rendered with some special tricks to get a more smoke-like appearance. 

All functions in the particle API, except for SpawnParticle modify properties in the particle state, which is then used when emitting particles, so the idea is to set up a state, and then emit one or several particles using that state. 

Most properties in the particle state can be either constant or animated over time. Supply a single argument for constant, two argument for linear interpolation, and optionally a third argument for other types of interpolation. There are also fade in and fade out parameters that fade from and to zero. 

ParticleReset ParticleType ParticleTile ParticleColor ParticleRadius ParticleAlpha ParticleGravity ParticleDrag ParticleEmissive ParticleRotation ParticleStretch ParticleSticky ParticleCollide ParticleFlags SpawnParticle

* * *

## Spawn

Functions to spawn entities in the scene. The Spawn function can spawn prefabs from file or xml. 

Spawn SpawnLayer SpawnTool

* * *

## Miscellaneous

Functions of peripheral nature that doesn't fit in anywhere else 

AddMapMarker SelectedMapMarker Shoot Paint PaintRGBA MakeHole Explosion SpawnFire GetFireCount QueryClosestFire QueryAabbFireCount RemoveAabbFires GetCameraTransform SetCameraTransform RequestFirstPerson RequestThirdPerson SetCameraOffsetTransform AttachCameraTo SetPivotClipBody ShakeCamera SetCameraFov SetCameraDof DisableMotionBlur SetLowHealthBlurThreshold PointLight SetTimeScale SetEnvironmentDefault SetEnvironmentProperty GetEnvironmentProperty SetPostProcessingDefault SetPostProcessingProperty GetPostProcessingProperty DrawLine DebugLine DebugCross DebugTransform DebugWatch DebugPrint RegisterListenerTo UnregisterListener TriggerEvent LoadHaptic CreateHaptic PlayHaptic PlayHapticDirectional HapticIsPlaying SetToolHaptic StopHaptic AddHeat GetBoundaryArea GetBoundaryBounds GetGravity SetGravity GetFps

* * *

## User Interface

The user interface functions are used for drawing interactive 2D graphics and can only be called from the draw function of a script. The ui functions are designed with the immediate mode gui paradigm in mind and uses a cursor and state stack. Pushing and popping the stack is cheap and designed to be called often. 

UiMakeInteractive UiPush UiPop UiWidth UiHeight UiCenter UiMiddle UiColor UiColorFilter UiResetColor UiTranslate UiRotate UiScale UiGetScale UiClipRect UiWindow UiGetCurrentWindow UiIsInCurrentWindow UiIsRectFullyClipped UiIsInClipRegion UiIsFullyClipped UiSafeMargins UiCanvasSize UiAlign UiTextAlignment UiModalBegin UiModalEnd UiDisableInput UiEnableInput UiReceivesInput UiGetMousePos UiGetCanvasMousePos UiIsMouseInRect UiWorldToPixel UiPixelToWorld UiGetCursorPos UiBlur UiFont UiFontHeight UiText UiTextDisableWildcards UiTextUniformHeight UiGetTextSize UiMeasureText UiGetSymbolsCount UiTextSymbolsSub UiWordWrap UiTextLineSpacing UiTextOutline UiTextShadow UiRect UiRectOutline UiRoundedRect UiRoundedRectOutline UiCircle UiCircleOutline UiFillImage UiBackgroundBlur UiImage UiUnloadImage UiHasImage UiGetImageSize UiImageBox UiSound UiSoundLoop UiMute UiButtonImageBox UiButtonHoverColor UiButtonPressColor UiButtonPressDist UiButtonTextHandling UiTextButton UiImageButton UiBlankButton UiSlider UiSliderHoverColorFilter UiSliderThumbSize UiGetScreen UiNavComponent UiIgnoreNavigation UiResetNavigation UiNavSkipUpdate UiIsComponentInFocus UiNavGroupBegin UiNavGroupEnd UiNavGroupSize UiForceFocus UiFocusedComponentId UiFocusedComponentRect UiGetItemSize UiAutoTranslate UiBeginFrame UiResetFrame UiFrameOccupy UiEndFrame UiFrameSkipItem UiGetFrameNo UiGetLanguage UiSetCursorState

* * *

### GetIntParam 
    
    
    value = GetIntParam(name, default)

Arguments  
name (string) - Parameter name  
default (number) - Default parameter value  


Return value  
value (number) - Parameter value  

    
    
    
    --Retrieve blinkcount parameter, or set to 5 if omitted
    parameterBlinkCount = GetIntParam("blinkcount", 5)
    
    function init()
    	DebugPrint(parameterBlinkCount)
    end
    
    

* * *

### GetFloatParam 
    
    
    value = GetFloatParam(name, default)

Arguments  
name (string) - Parameter name  
default (number) - Default parameter value  


Return value  
value (number) - Parameter value  

    
    
    
    --Retrieve speed parameter, or set to 10.0 if omitted
    parameterSpeed = GetFloatParam("speed", 10.0)
    
    function init()
    	DebugPrint(parameterSpeed)
    end
    
    

* * *

### GetBoolParam 
    
    
    value = GetBoolParam(name, default)

Arguments  
name (string) - Parameter name  
default (boolean) - Default parameter value  


Return value  
value (boolean) - Parameter value  

    
    
    
    --Retrieve playsound parameter, or false if omitted
    parameterPlaySound = GetBoolParam("playsound", false)
    
    
    function init()
    	DebugPrint(parameterPlaySound)
    end
    
    

* * *

### GetStringParam 
    
    
    value = GetStringParam(name, default)

Arguments  
name (string) - Parameter name  
default (string) - Default parameter value  


Return value  
value (string) - Parameter value  

    
    
    
    --Retrieve mode parameter, or "idle" if omitted
    parameterMode = GetStringParam("mode", "idle")
    
    function init()
    	DebugPrint(parameterMode)
    end
    
    

* * *

### GetColorParam 
    
    
    value = GetColorParam(name, default)

Arguments  
name (string) - Parameter name  
default (number) - Default parameter value  


Return value  
value (number) - Parameter value  

    
    
    
    --Retrieve color parameter, or set to 0.39, 0.39, 0.39 if omitted
    color_r, color_g, color_b = GetColorParam("color", 0.39, 0.39, 0.39)
    
    function init()
    	DebugPrint(color_r .. " " .. color_g .. " " .. color_b)
    end
    
    

* * *

### GetVersion 
    
    
    version = GetVersion()

Arguments  
none

Return value  
version (string) - Dot separated string of current version of the game  

    
    
    function init()
    	local v = GetVersion()
    	--v is "0.5.0"
    	DebugPrint(v)
    end
    
    

* * *

### HasVersion 
    
    
    match = HasVersion(version)

Arguments  
version (string) - Reference version  


Return value  
match (boolean) - True if current version is at least provided one  

    
    
    function init()
    	if HasVersion("1.5.0") then
    		--conditional code that only works on 0.6.0 or above
    		DebugPrint("New version")
    	else
    		--legacy code that works on earlier versions
    		DebugPrint("Earlier version")
    	end
    end
    
    

* * *

### GetTime 
    
    
    time = GetTime()

Arguments  
none

Return value  
time (number) - The time in seconds since level was started  


Returns running time of this script. If called from update, this returns the simulated time, otherwise it returns wall time. 
    
    
    function client.update()
    	local t = GetTime()
    	DebugPrint(t)
    end
    
    

* * *

### GetTimeStep 
    
    
    dt = GetTimeStep()

Arguments  
none

Return value  
dt (number) - The timestep in seconds  


Returns timestep of the last frame. If called from update, this returns the simulation time step, which is always one 60th of a second (0.0166667). If called from tick or draw it returns the actual time since last frame. 
    
    
    function client.tick()
    	local dt = GetTimeStep()
    	DebugPrint("tick dt: " .. dt)
    end
    
    function client.update()
    	local dt = GetTimeStep()
    	DebugPrint("update dt: " .. dt)
    end
    
    

* * *

### InputLastPressedKey 
    
    
    name = InputLastPressedKey([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
name (string) - Name of last pressed key, empty if no key is pressed  

    
    
    function client.tick()
    	local name = InputLastPressedKey()
    	if string.len(name) > 0 then
    		DebugPrint(name)
    	end
    end
    
    

* * *

### InputPressed 
    
    
    pressed = InputPressed(input, [playerId])

Arguments  
input (string) - The input identifier  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
pressed (boolean) - True if input was pressed during last frame  

    
    
    function client.tick()
    	if InputPressed("interact") then
    		DebugPrint("interact")
    	end
    end
    
    

* * *

### InputReleased 
    
    
    pressed = InputReleased(input, [playerId])

Arguments  
input (string) - The input identifier  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
pressed (boolean) - True if input was released during last frame  

    
    
    function client.tick()
    	if InputReleased("interact") then
    		DebugPrint("interact")
    	end
    end
    
    

* * *

### InputDown 
    
    
    pressed = InputDown(input, [playerId])

Arguments  
input (string) - The input identifier  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
pressed (boolean) - True if input is currently held down  

    
    
    function client.tick()
    	if InputDown("interact") then
    		DebugPrint("interact")
    	end
    end
    
    

* * *

### InputValue 
    
    
    value = InputValue(input, [playerId])

Arguments  
input (string) - The input identifier  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
value (number) - Depends on input type  

    
    
    local scrollPos = 0
    function client.tick()
    	scrollPos = scrollPos + InputValue("mousewheel")
    	DebugPrint(scrollPos)
    end
    
    

* * *

### InputClear CLIENT ONLY
    
    
    InputClear()

Arguments  
none

Return value  
none

All player input is "forgotten" by the game after calling this function 
    
    
    function client.update()
        -- Prints '2' because InputClear() allows the game to "forget" the player's input
    	if InputDown("interact") then
            InputClear()
    		if InputDown("interact") then
    			DebugPrint(1)
    		else
    			DebugPrint(2)
    		end
    	end
    end
    
    

* * *

### InputResetOnTransition CLIENT ONLY
    
    
    InputResetOnTransition()

Arguments  
none

Return value  
none

This function will reset everything we need to reset during state transition 
    
    
    function update()
    	if InputDown("interact") then
            -- In this form, you won't be able to notice the result of the function; you need a specific context
    		InputResetOnTransition()
    	end
    end
    
    

* * *

### LastInputDevice 
    
    
    value = LastInputDevice()

Arguments  
none

Return value  
value (number) - Last device id  


Returns the last input device id. 0 - none, 1 - mouse, 2 - gamepad 
    
    
    #include "ui/ui_helpers.lua"
    
    function client.update()
    	if LastInputDevice() == UI_DEVICE_GAMEPAD then
    		DebugPrint("Last input was from gamepad")
    	elseif LastInputDevice() == UI_DEVICE_MOUSE then
    		DebugPrint("Last input was mouse & keyboard")
    	elseif LastInputDevice() == UI_DEVICE_TOUCHSCREEN then
    		DebugPrint("Last input was touchscreen")
    	end
    end
    
    

* * *

### SetValue 
    
    
    SetValue(variable, value, [transition], [time])

Arguments  
variable (string) - Name of number variable in the global context  
value (number) - The new value  
transition (string, optional) - Transition type. See description.  
time (number, optional) - Transition time (seconds)  


Return value  
none

Set value of a number variable in the global context with an optional transition. If a transition is provided the value will animate from current value to the new value during the transition time. Transition can be one of the following:  Transition |  Description  
---|---  
linear |  Linear transition  
cosine |  Slow at beginning and end  
easein |  Slow at beginning  
easeout |  Slow at end  
bounce |  Bounce and overshoot new value  
      
    
    myValue = 0
    function client.tick()
    	--This will change the value of myValue from 0 to 1 in a linear fasion over 0.5 seconds
    	SetValue("myValue", 1, "linear", 0.5)
    	DebugPrint(myValue)
    end
    
    

* * *

### SetValueInTable 
    
    
    SetValueInTable(tableId, memberName, newValue, type, length)

Arguments  
tableId (table) - Id of the table  
memberName (string) - Name of the member  
newValue (number) - New value  
type (string) - Transition type  
length (number) - Transition length  


Return value  
none

Chages the value of a table member in time according to specified args. Works similar to SetValue but for global variables of trivial types 
    
    
    local t = {}
    function init()
    	SetValueInTable(t, "score", 1, "number", 1)
    end
    function update()
    	if InputPressed("interact") then
    		SetValueInTable(t, "score", t.score + 1, "number", 1)
            DebugPrint(t.score)
    	end
    end
    
    

* * *

### PauseMenuButton 
    
    
    clicked = PauseMenuButton(title, [location], [disabled])

Arguments  
title (string) - Text on button  
location (string, optional) - Button location. If "bottom_bar" - bottom bar, if "main_bottom" - below "Main menu" button, if "main_top" - above "Main menu" button. Default "bottom_bar".  
disabled (bool, optional) - Disable button. Button will be rendered as grayed out. Default is false. Only available when used with "bottom_bar".  


Return value  
clicked (boolean) - True if clicked, false otherwise  


Calling this function will add a button on the bottom bar or in the main pause menu (center of the screen) when the game is paused. Identified by 'location' parameter, it can be below "Main menu" button (by passing "main_bottom" value)or above (by passing "main_top"). A primary button will be placed in the main pause menu if this function is called from a playable mod. There can be only one primary button. Use this as a way to bring up mod settings or other user interfaces while the game is running. Call this function every frame from the tick function for as long as the pause menu button should still be visible. Only one button per script is allowed. Consecutive calls replace button added in previous calls. 
    
    
    
    function server.startLevel(mission, path)
    	StartLevel(mission, path)
    end
    
    function server.respawnPlayer(player)
    	-- Respawn player
    end
    
    function client.tick()
    
    
    	for p in Players() do
    		if IsPlayerHost(p) then
    			-- Primary button which will be placed in the main pause menu below "Main menu" button
    			if PauseMenuButton("Back to Hub", "main_bottom") then
    				ServerCall("server.startLevel", "hub", "level/hub.xml")	
    			end
    
    			-- Primary button which will be placed in the main pause menu above "Main menu" button
    			if PauseMenuButton("Back to Hub", "main_top") then
    				ServerCall("server.startLevel", "hub", "level/hub.xml")
    			end
    
    			-- Button will be placed in the bottom bar of the pause menu
    			if PauseMenuButton("MyMod Settings") then
    				visible = true
    			end
    		else
    			if PauseMenuButton("Respawn (wait 8s)", "bottom_bar", true) then
    				ServerCall("server.respawnPlayer", p)
    			end
    		end
    	end
    end
    
    function draw()
    	if visible then
    		UiMakeInteractive()
    	end
    end
    
    
    

* * *

### HasFile 
    
    
    exists = HasFile(path)

Arguments  
path (string) - Path to file  


Return value  
exists (boolean) - True if file exists  


Checks that file exists on the specified path. It is preferable to use UiHasImage whenever possible - it has better performance 
    
    
    local file = "gfx/circle.png"
    
    function draw()
    	if HasFile(image) then
    		DebugPrint("file " .. file .. " exists")
    	end
    end
    
    

* * *

### StartLevel 
    
    
    StartLevel(mission, path, [layers], [passThrough])

Arguments  
mission (string) - An identifier of your choice  
path (string) - Path to level XML file  
layers (string, optional) - Active layers. Default is no layers.  
passThrough (boolean, optional) - If set, loading screen will have no text and music will keep playing  


Return value  
none

Start a level 
    
    
    function server.init()
    	--Start level with no active layers
    	StartLevel("level1", "MOD/level1.xml")
    
    	--Start level with two layers
    	StartLevel("level1", "MOD/level1.xml", "vehicles targets")
    end
    
    

* * *

### SetPaused 
    
    
    SetPaused(paused)

Arguments  
paused (boolean) - True if game should be paused  


Return value  
none

Set paused state of the game 
    
    
    
    function client.tick()
    	if InputPressed("interact") then
    		--Pause game and bring up pause menu on HUD
    		SetPaused(true)
    	end
    end
    
    

* * *

### Restart 
    
    
    Restart()

Arguments  
none

Return value  
none

Restart level 
    
    
    
    
    function server.tick()
    	if InputPressed("interact") then
    		Restart()
    	end
    end
    
    

* * *

### Menu 
    
    
    Menu()

Arguments  
none

Return value  
none

Go to main menu 
    
    
    function client.tick()
    	if InputPressed("interact") then
    		Menu()
    	end
    end
    
    

* * *

### ClientCall 
    
    
    ClientCall(playerId, function, [param1, param2, .., paramN])

Arguments  
playerId (number) - Player ID of the recipient. Use 0 to broadcast to every player.  
function (string) - Name of the function to be invoked. This function must exist within issuing script.  
param1, param2, .., paramN (any, optional) - Optional parameters to send to the recipent(s). Arguments should match the signature of the specified function.  


Return value  
none
    
    
    
    function server.tick()
    	for p in Players() do
    		if GetPlayerHealth(p) == 0) then
    			ClientCall(p, "client.showRespawnBtn")
    		end
    	end
    	
    	if matchEnded then
    		ClientCall(0, "client.displayParticles", "confetti", 200, 0.3, Vec(0, 30, 0))
    	end
    end
    
    function client.showRespawnBtn()
    	-- show respawn ui..
    end
    
    function client.displayParticles(particleName, amount, life, pos)
    	-- spawn particles..
    end
    
    

* * *

### ServerCall 
    
    
    ServerCall(function, [param1, param2, .., paramN])

Arguments  
function (string) - Name of the function to be invoked. This function must exist within issuing script.  
param1, param2, .., paramN (any, optional) - Optional parameters to send to the server. Arguments should match the signature of the specified function.  


Return value  
none
    
    
    function client.tick()
    	if UiTextButton("I am Ready") then
    		ServerCall("server.setPlayerReady", GetLocalPlayer()) 
    	end
    end
    
    function server.setPlayerReady(playerId)
    	shared.playersReady[playerId] = true
    end
    
    

* * *

### ClearKey 
    
    
    ClearKey(key)

Arguments  
key (string) - Registry key to clear  


Return value  
none

Remove registry node, including all child nodes. 
    
    
    function init()
    	--If the registry looks like this:
    	--	score
    	--		levels
    	--			level1 = 5
    	--			level2 = 4
    
    	ClearKey("score.levels")
    
    	--Afterwards, the registry will look like this:
    	--	score
    end
    
    

* * *

### ListKeys 
    
    
    children = ListKeys(parent)

Arguments  
parent (string) - The parent registry key  


Return value  
children (table) - Indexed table of strings with child keys  


List all child keys of a registry node. 
    
    
    --If the registry looks like this:
    --	game
    --		tool
    --			steroid
    --			rifle
    --			...
    
    function init()
    	local list = ListKeys("game.tool")
    	for i=1, #list do
    		DebugPrint(list[i])
    	end
    end
    
    --This will output:
    --steroid
    --rifle
    -- ...
    
    

* * *

### HasKey 
    
    
    exists = HasKey(key)

Arguments  
key (string) - Registry key  


Return value  
exists (boolean) - True if key exists  


Returns true if the registry contains a certain key 
    
    
    function init()
    	DebugPrint(HasKey("score.levels"))
    	DebugPrint(HasKey("game.tool.rifle"))
    end
    
    

* * *

### SetInt 
    
    
    SetInt(key, value, [sync])

Arguments  
key (string) - Registry key  
value (number) - Desired value  
sync (boolean, optional) - Synchronize to clients  


Return value  
none
    
    
    function init()
    	SetInt("score.levels.level1", 4)
    	DebugPrint(GetInt("score.levels.level1"))
    end
    
    

* * *

### GetInt 
    
    
    value = GetInt(key)

Arguments  
key (string) - Registry key  


Return value  
value (number) - Integer value of registry node or zero if not found  

    
    
    function init()
    	SetInt("score.levels.level1", 4)
    	DebugPrint(GetInt("score.levels.level1"))
    end
    
    

* * *

### SetFloat 
    
    
    SetFloat(key, value, [sync])

Arguments  
key (string) - Registry key  
value (number) - Desired value  
sync (boolean, optional) - Synchronize to clients  


Return value  
none
    
    
    function init()
    	SetFloat("level.time", 22.3)
    	DebugPrint(GetFloat("level.time"))
    end
    
    

* * *

### GetFloat 
    
    
    value = GetFloat(key)

Arguments  
key (string) - Registry key  


Return value  
value (number) - Float value of registry node or zero if not found  

    
    
    function init()
    	SetFloat("level.time", 22.3)
    	DebugPrint(GetFloat("level.time"))
    end
    
    

* * *

### SetBool 
    
    
    SetBool(key, value, [sync])

Arguments  
key (string) - Registry key  
value (boolean) - Desired value  
sync (boolean, optional) - Synchronize to clients  


Return value  
none
    
    
    function init()
    	SetBool("level.robots.enabled", true)
    	DebugPrint(GetBool("level.robots.enabled"))
    end
    
    

* * *

### GetBool 
    
    
    value = GetBool(key)

Arguments  
key (string) - Registry key  


Return value  
value (boolean) - Boolean value of registry node or false if not found  

    
    
    function init()
    	SetBool("level.robots.enabled", true)
    	DebugPrint(GetBool("level.robots.enabled"))
    end
    
    

* * *

### SetString 
    
    
    SetString(key, value, [sync])

Arguments  
key (string) - Registry key  
value (string) - Desired value  
sync (boolean, optional) - Synchronize to clients  


Return value  
none
    
    
    function init()
    	SetString("level.name", "foo")
    	DebugPrint(GetString("level.name"))
    end
    
    

* * *

### GetString 
    
    
    value = GetString(key)

Arguments  
key (string) - Registry key  


Return value  
value (string) - String value of registry node or "" if not found  

    
    
    function init()
    	SetString("level.name", "foo")
    	DebugPrint(GetString("level.name"))
    end
    
    

* * *

### SetColor 
    
    
    SetColor(key, r, g, b, [a])

Arguments  
key (string) - Registry key  
r (number) - Desired red channel value  
g (number) - Desired green channel value  
b (number) - Desired blue channel value  
a (number, optional) - Desired alpha channel value  


Return value  
none

Sets the color registry key value 
    
    
    function init()
    	SetColor("game.tool.wire.color", 1.0, 0.5, 0.3)
    end
    
    

* * *

### GetColor 
    
    
    r, g, b, a = GetColor(key)

Arguments  
key (string) - Registry key  


Return value  
r (number) - Desired red channel value  
g (number) - Desired green channel value  
b (number) - Desired blue channel value  
a (number) - Desired alpha channel value  


Returns the color registry key value 
    
    
    function init()
    	SetColor("red", 1.0, 0.1, 0.1)
    	color = GetColor("red")
    	DebugPrint("RGBA: " .. color[1] .. " " .. color[2] .. " " .. color[3] .. " " .. color[4])
    end
    
    

* * *

### GetTranslatedStringByKey 
    
    
    value = GetTranslatedStringByKey(key, [default])

Arguments  
key (string) - Translation key  
default (string, optional) - Default value  


Return value  
value (string) - Translation  


Returns the translation for the specified key from the translation table. If the key is not found returns the default value 
    
    
    function init()
    	DebugPrint(GetTranslatedStringByKey("TOOL_CAMERA"))
    end
    
    

* * *

### HasTranslationByKey 
    
    
    value = HasTranslationByKey(key)

Arguments  
key (string) - Translation key  


Return value  
value (boolean) - True if translation exists  


Checks that translation for specified key exists 
    
    
    function init()
    	DebugPrint(HasTranslationByKey("TOOL_CAMERA"))
    end
    
    

* * *

### LoadLanguageTable 
    
    
    LoadLanguageTable(id)

Arguments  
id (number) - Language id (enum)  


Return value  
none

Loads the language table for specified language id for further localization. Possible id values are:  
 Id |  Language  
---|---  
0 |  English  
1 |  French  
2 |  Spanish  
3 |  Italian  
4 |  German  
5 |  Simplified Chinese  
6 |  Japanese  
7 |  Russian  
8 |  Polish  
      
    
    function init()
    	-- loads the english localization table
    	LoadLanguageTable(0)
    end
    
    

* * *

### GetUserNickname 
    
    
    value = GetUserNickname([id])

Arguments  
id (number, optional) - User id  


Return value  
value (string) - User nickname  


Returns the user nickname with the specified id. If id is not specified, returns nickname for user with id '0' 
    
    
    function init()
    	DebugPrint(GetUserNickname(0))
    end
    
    

* * *

### GetEventCount 
    
    
    value = GetEventCount(type)

Arguments  
type (string) - Event type  


Return value  
value (number) - Number of event available  

    
    
    local count = GetEventCount("matchended")
    for i=1, count do
    	local name1, name2, score1, score2 = GetEvent("matchended", i)
    end
    
    

* * *

### PostEvent 
    
    
    PostEvent(eventName, [param1, param2, .., paramN])

Arguments  
eventName (string) - Event name  
param1, param2, .., paramN (any, optional) - Optional parameters to send with the event.  


Return value  
none

Post a custom event with the specified name and parameters. The parameters will be saved in a memory stream and can be retrieved later using GetEvent. 
    
    
    PostEvent("matchended", "team1", "team2", 5, 10)
    
    

* * *

### GetEvent 
    
    
    returnValues = GetEvent(type, index)

Arguments  
type (string) - Event type  
index (number) - Event index (starting with one)  


Return value  
returnValues (varying) - Return values depending on event type  

    
    
    local count = GetEventCount("matchended")
    for i=1, count do
    	local name1, name2, score1, score2 = GetEvent("matchended", i)
    end
    
    

* * *

### Vec 
    
    
    vec = Vec([x], [y], [z])

Arguments  
x (number, optional) - X value  
y (number, optional) - Y value  
z (number, optional) - Z value  


Return value  
vec (TVec) - New vector  


Create new vector and optionally initializes it to the provided values. A Vec is equivalent to a regular lua table with three numbers. 
    
    
    function init()
    	--These are equivalent
    	local a1 = Vec()
    	local a2 = {0, 0, 0}
    	DebugPrint("a1 == a2: " .. tostring(VecStr(a1) == VecStr(a2)))
    
    	--These are equivalent
    	local b1 = Vec(0, 1, 0)
    	local b2 = {0, 1, 0}
    	DebugPrint("b1 == b2: " .. tostring(VecStr(b1) == VecStr(b2)))
    end
    
    

* * *

### VecCopy 
    
    
    new = VecCopy(org)

Arguments  
org (TVec) - A vector  


Return value  
new (TVec) - Copy of org vector  


Vectors should never be assigned like regular numbers. Since they are implemented with lua tables assignment means two references pointing to the same data. Use this function instead. 
    
    
    function init()
    	--Do this to assign a vector
    	local right1 = Vec(1, 2, 3)
    	local right2 = VecCopy(right1)
    
    	--Never do this unless you REALLY know what you're doing
    	local wrong1 = Vec(1, 2, 3)
    	local wrong2 = wrong1
    end
    
    

* * *

### VecStr 
    
    
    str = VecStr(vector)

Arguments  
vector (TVec) - Vector  


Return value  
str (string) - String representation  


Returns the string representation of vector 
    
    
    function init()
    	local v = Vec(0, 10, 0)
    	DebugPrint(VecStr(v))
    end
    
    

* * *

### VecLength 
    
    
    length = VecLength(vec)

Arguments  
vec (TVec) - A vector  


Return value  
length (number) - Length (magnitude) of the vector  

    
    
    function init()
    	local v = Vec(1,1,0)
    	local l = VecLength(v)
    	--l now equals 1.4142
    	DebugPrint(l)
    end
    
    

* * *

### VecNormalize 
    
    
    norm = VecNormalize(vec)

Arguments  
vec (TVec) - A vector  


Return value  
norm (TVec) - A vector of length 1.0  


If the input vector is of zero length, the function returns {0,0,1} 
    
    
    function init()
    	local v = Vec(0,3,0)
    	local n = VecNormalize(v)
    	--n now equals {0,1,0}
    	DebugPrint(VecStr(n))
    end
    
    

* * *

### VecScale 
    
    
    norm = VecScale(vec, scale)

Arguments  
vec (TVec) - A vector  
scale (number) - A scale factor  


Return value  
norm (TVec) - A scaled version of input vector  

    
    
    function init()
    	local v = Vec(1,2,3)
    	local n = VecScale(v, 2)
    	--n now equals {2,4,6}
    	DebugPrint(VecStr(n))
    end
    
    

* * *

### VecAdd 
    
    
    c = VecAdd(a, b)

Arguments  
a (TVec) - Vector  
b (TVec) - Vector  


Return value  
c (TVec) - New vector with sum of a and b  

    
    
    function init()
    	local a = Vec(1,2,3)
    	local b = Vec(3,0,0)
    	local c = VecAdd(a, b)
    	--c now equals {4,2,3}
    	DebugPrint(VecStr(c))
    end
    
    

* * *

### VecSub 
    
    
    c = VecSub(a, b)

Arguments  
a (TVec) - Vector  
b (TVec) - Vector  


Return value  
c (TVec) - New vector representing a-b  

    
    
    function init()
    	local a = Vec(1,2,3)
    	local b = Vec(3,0,0)
    	local c = VecSub(a, b)
    	--c now equals {-2,2,3}
    	DebugPrint(VecStr(c))
    end
    
    

* * *

### VecDot 
    
    
    c = VecDot(a, b)

Arguments  
a (TVec) - Vector  
b (TVec) - Vector  


Return value  
c (number) - Dot product of a and b  

    
    
    function init()
    	local a = Vec(1,2,3)
    	local b = Vec(3,1,0)
    	local c = VecDot(a, b)
    	--c now equals 5
    	DebugPrint(c)
    end
    
    

* * *

### VecCross 
    
    
    c = VecCross(a, b)

Arguments  
a (TVec) - Vector  
b (TVec) - Vector  


Return value  
c (TVec) - Cross product of a and b (also called vector product)  

    
    
    function init()
    	local a = Vec(1,0,0)
    	local b = Vec(0,1,0)
    	local c = VecCross(a, b)
    	--c now equals {0,0,1}
    	DebugPrint(VecStr(c))
    end
    
    

* * *

### VecLerp 
    
    
    c = VecLerp(a, b, t)

Arguments  
a (TVec) - Vector  
b (TVec) - Vector  
t (number) - fraction (usually between 0.0 and 1.0)  


Return value  
c (TVec) - Linearly interpolated vector between a and b, using t  

    
    
    function init()
    	local a = Vec(2,0,0)
    	local b = Vec(0,4,2)
    	local t = 0.5
    	
    	--These two are equivalent
    	local c1 = VecLerp(a, b, t)
    	local c2 = VecAdd(VecScale(a, 1-t), VecScale(b, t))
    	
    	--c1 and c2 now equals {1, 2, 1}
    	DebugPrint("c1" .. VecStr(c1) .. " == c2" .. VecStr(c2))
    end
    
    

* * *

### Quat 
    
    
    quat = Quat([x], [y], [z], [w])

Arguments  
x (number, optional) - X value  
y (number, optional) - Y value  
z (number, optional) - Z value  
w (number, optional) - W value  


Return value  
quat (TQuat) - New quaternion  


Create new quaternion and optionally initializes it to the provided values. Do not attempt to initialize a quaternion with raw values unless you know what you are doing. Use QuatEuler or QuatAxisAngle instead. If no arguments are given, a unit quaternion will be created: {0, 0, 0, 1}. A quaternion is equivalent to a regular lua table with four numbers. 
    
    
    function init()
    	--These are equivalent
    	local a1 = Quat()
    	local a2 = {0, 0, 0, 1}
    
    	DebugPrint(QuatStr(a1) == QuatStr(a2))
    end
    
    

* * *

### QuatCopy 
    
    
    new = QuatCopy(org)

Arguments  
org (TQuat) - Quaternion  


Return value  
new (TQuat) - Copy of org quaternion  


Quaternions should never be assigned like regular numbers. Since they are implemented with lua tables assignment means two references pointing to the same data. Use this function instead. 
    
    
    function init()
    	--Do this to assign a quaternion
    	local right1 = QuatEuler(0, 90, 0)
    	local right2 = QuatCopy(right1)
    
    	--Never do this unless you REALLY know what you're doing
    	local wrong1 = QuatEuler(0, 90, 0)
    	local wrong2 = wrong1
    end
    
    

* * *

### QuatAxisAngle 
    
    
    quat = QuatAxisAngle(axis, angle)

Arguments  
axis (TVec) - Rotation axis, unit vector  
angle (number) - Rotation angle in degrees  


Return value  
quat (TQuat) - New quaternion  


Create a quaternion representing a rotation around a specific axis 
    
    
    function init()
    	--Create quaternion representing rotation 30 degrees around Y axis
    	local q = QuatAxisAngle(Vec(0,1,0), 30)
    	DebugPrint(QuatStr(q))
    end
    
    

* * *

### QuatDeltaNormals 
    
    
    quat = QuatDeltaNormals(normal0, normal1)

Arguments  
normal0 (TVec) - Unit vector  
normal1 (TVec) - Unit vector  


Return value  
quat (TQuat) - New quaternion  


Create a quaternion representing a rotation between the input normals 
    
    
    function init()
    	--Create quaternion representing a rotation between x-axis and y-axis
    	local q = QuatDeltaNormals(Vec(1,0,0), Vec(0,1,0))
    end
    
    

* * *

### QuatDeltaVectors 
    
    
    quat = QuatDeltaVectors(vector0, vector1)

Arguments  
vector0 (TVec) - Vector  
vector1 (TVec) - Vector  


Return value  
quat (TQuat) - New quaternion  


Create a quaternion representing a rotation between the input vectors that doesn't need to be of unit-length 
    
    
    function init()
    	--Create quaternion representing a rotation between two non-unit vectors aligned along x-axis and y-axis
    	local q = QuatDeltaVectors(Vec(10,0,0), Vec(0,5,0))
    end
    
    

* * *

### QuatEuler 
    
    
    quat = QuatEuler(x, y, z)

Arguments  
x (number) - Angle around X axis in degrees, sometimes also called roll or bank  
y (number) - Angle around Y axis in degrees, sometimes also called yaw or heading  
z (number) - Angle around Z axis in degrees, sometimes also called pitch or attitude  


Return value  
quat (TQuat) - New quaternion  


Create quaternion using euler angle notation. The order of applied rotations uses the "NASA standard aeroplane" model: 

  1. Rotation around Y axis (yaw or heading)
  2. Rotation around Z axis (pitch or attitude)
  3. Rotation around X axis (roll or bank)


    
    
    function init()
    	--Create quaternion representing rotation 30 degrees around Y axis and 25 degrees around Z axis
    	local q = QuatEuler(0, 30, 25)
    end
    
    

* * *

### QuatAlignXZ 
    
    
    quat = QuatAlignXZ(xAxis, zAxis)

Arguments  
xAxis (TVec) - X axis  
zAxis (TVec) - Z axis  


Return value  
quat (TQuat) - Quaternion  


Return the quaternion aligned to specified axes 
    
    
    function update()
    	local laserSprite = LoadSprite("gfx/laser.png")
    	local origin = Vec(0, 0, 0)
    	local dir = Vec(1, 0, 0)
    	local length = 10
    	local hitPoint = VecAdd(origin, VecScale(dir, length))
    	local t = Transform(VecLerp(origin, hitPoint, 0.5))
    	local xAxis = VecNormalize(VecSub(hitPoint, origin))
    	local zAxis = VecNormalize(VecSub(origin, GetCameraTransform().pos))
    	t.rot = QuatAlignXZ(xAxis, zAxis)
    	DrawSprite(laserSprite, t, length, 0.05+math.random()*0.01, 8, 4, 4, 1, true, true)
    	DrawSprite(laserSprite, t, length, 0.5, 1.0, 0.3, 0.3, 1, true, true)
    end
    
    

* * *

### GetQuatEuler 
    
    
    x, y, z = GetQuatEuler(quat)

Arguments  
quat (TQuat) - Quaternion  


Return value  
x (number) - Angle around X axis in degrees, sometimes also called roll or bank  
y (number) - Angle around Y axis in degrees, sometimes also called yaw or heading  
z (number) - Angle around Z axis in degrees, sometimes also called pitch or attitude  


Return euler angles from quaternion. The order of rotations uses the "NASA standard aeroplane" model: 

  1. Rotation around Y axis (yaw or heading)
  2. Rotation around Z axis (pitch or attitude)
  3. Rotation around X axis (roll or bank)


    
    
    function init()
    	--Return euler angles from quaternion q
    	q = QuatEuler(30, 45, 0)
    	rx, ry, rz = GetQuatEuler(q)
    	DebugPrint(rx .. " " .. ry .. " " .. rz)
    end
    
    

* * *

### QuatLookAt 
    
    
    quat = QuatLookAt(eye, target)

Arguments  
eye (TVec) - Vector representing the camera location  
target (TVec) - Vector representing the point to look at  


Return value  
quat (TQuat) - New quaternion  


Create a quaternion pointing the negative Z axis (forward) towards a specific point, keeping the Y axis upwards. This is very useful for creating camera transforms. 
    
    
    function init()
    	local eye = Vec(0, 10, 0)
    	local target = Vec(0, 1, 5)
    	local rot = QuatLookAt(eye, target)
    	SetCameraTransform(Transform(eye, rot))
    end
    
    

* * *

### QuatSlerp 
    
    
    c = QuatSlerp(a, b, t)

Arguments  
a (TQuat) - Quaternion  
b (TQuat) - Quaternion  
t (number) - fraction (usually between 0.0 and 1.0)  


Return value  
c (TQuat) - New quaternion  


Spherical, linear interpolation between a and b, using t. This is very useful for animating between two rotations. 
    
    
    function init()
    	local a = QuatEuler(0, 10, 0)
    	local b = QuatEuler(0, 0, 45)
    
    	--Create quaternion half way between a and b
    	local q = QuatSlerp(a, b, 0.5)
    	DebugPrint(QuatStr(q))
    end
    
    

* * *

### QuatStr 
    
    
    str = QuatStr(quat)

Arguments  
quat (TQuat) - Quaternion  


Return value  
str (string) - String representation  


Returns the string representation of quaternion 
    
    
    function init()
    	local q = QuatEuler(0, 10, 0)
    	DebugPrint(QuatStr(q))
    end
    
    

* * *

### QuatRotateQuat 
    
    
    c = QuatRotateQuat(a, b)

Arguments  
a (TQuat) - Quaternion  
b (TQuat) - Quaternion  


Return value  
c (TQuat) - New quaternion  


Rotate one quaternion with another quaternion. This is mathematically equivalent to c = a * b using quaternion multiplication. 
    
    
    function init()
    	local a = QuatEuler(0, 10, 0)
    	local b = QuatEuler(0, 0, 45)
    	local q = QuatRotateQuat(a, b)
    
    	--q now represents a rotation first 10 degrees around
    	--the Y axis and then 45 degrees around the Z axis.
    	local x, y, z = GetQuatEuler(q)
    	DebugPrint(x .. " " .. y .. " " .. z)
    end
    
    
    

* * *

### QuatRotateVec 
    
    
    vec = QuatRotateVec(a, vec)

Arguments  
a (TQuat) - Quaternion  
vec (TVec) - Vector  


Return value  
vec (TVec) - Rotated vector  


Rotate a vector by a quaternion 
    
    
    function init()
    	local q = QuatEuler(0, 10, 0)
    	local v = Vec(1, 0, 0)
    	local r = QuatRotateVec(q, v)
    	
    	--r is now vector a rotated 10 degrees around the Y axis
    	DebugPrint(VecStr(r))
    end
    
    

* * *

### Transform 
    
    
    transform = Transform([pos], [rot])

Arguments  
pos (TVec, optional) - Vector representing transform position  
rot (TQuat, optional) - Quaternion representing transform rotation  


Return value  
transform (TTransform) - New transform  


A transform is a regular lua table with two entries: pos and rot, a vector and quaternion representing transform position and rotation. 
    
    
    function init()
    	--Create transform located at {0, 0, 0} with no rotation
    	local t1 = Transform()
    
    	--Create transform located at {10, 0, 0} with no rotation
    	local t2 = Transform(Vec(10, 0,0))
    
    	--Create transform located at {10, 0, 0}, rotated 45 degrees around Y axis
    	local t3 = Transform(Vec(10, 0,0), QuatEuler(0, 45, 0))
    
    	DebugPrint(TransformStr(t1))
    	DebugPrint(TransformStr(t2))
    	DebugPrint(TransformStr(t3))
    end
    
    

* * *

### TransformCopy 
    
    
    new = TransformCopy(org)

Arguments  
org (TTransform) - Transform  


Return value  
new (TTransform) - Copy of org transform  


Transforms should never be assigned like regular numbers. Since they are implemented with lua tables assignment means two references pointing to the same data. Use this function instead. 
    
    
    function init()
    	--Do this to assign a quaternion
    	local right1 = Transform(Vec(1,0,0), QuatEuler(0, 90, 0))
    	local right2 = TransformCopy(right1)
    
    	--Never do this unless you REALLY know what you're doing
    	local wrong1 = Transform(Vec(1,0,0), QuatEuler(0, 90, 0))
    	local wrong2 = wrong1
    end
    
    

* * *

### TransformStr 
    
    
    str = TransformStr(transform)

Arguments  
transform (TTransform) - Transform  


Return value  
str (string) - String representation  


Returns the string representation of transform 
    
    
    function init()
    	local eye = Vec(0, 10, 0)
    	local target = Vec(0, 1, 5)
    	local rot = QuatLookAt(eye, target)
    	local t = Transform(eye, rot)
    	DebugPrint(TransformStr(t))
    end
    
    

* * *

### TransformToParentTransform 
    
    
    transform = TransformToParentTransform(parent, child)

Arguments  
parent (TTransform) - Transform  
child (TTransform) - Transform  


Return value  
transform (TTransform) - New transform  


Transform child transform out of the parent transform. This is the opposite of TransformToLocalTransform. 
    
    
    function init()
    	local b = GetBodyTransform(body)
    	local s = GetShapeLocalTransform(shape)
    
    	--b represents the location of body in world space
    	--s represents the location of shape in body space
    
    	local w = TransformToParentTransform(b, s)
    
    	--w now represents the location of shape in world space
    	DebugPrint(TransformStr(w))
    end
    
    

* * *

### TransformToLocalTransform 
    
    
    transform = TransformToLocalTransform(parent, child)

Arguments  
parent (TTransform) - Transform  
child (TTransform) - Transform  


Return value  
transform (TTransform) - New transform  


Transform one transform into the local space of another transform. This is the opposite of TransformToParentTransform. 
    
    
    function init()
    	local b = GetBodyTransform(body)
    	local w = GetShapeWorldTransform(shape)
    
    	--b represents the location of body in world space
    	--w represents the location of shape in world space
    	
    	local s = TransformToLocalTransform(b, w)
    
    	--s now represents the location of shape in body space.
    	DebugPrint(TransformStr(s))
    end
    
    

* * *

### TransformToParentVec 
    
    
    r = TransformToParentVec(t, v)

Arguments  
t (TTransform) - Transform  
v (TVec) - Vector  


Return value  
r (TVec) - Transformed vector  


Transfom vector v out of transform t only considering rotation. 
    
    
    function init()
    	local t = GetBodyTransform(body)
    	local localUp = Vec(0, 1, 0)
    	local up = TransformToParentVec(t, localUp)
    
    	--up now represents the local body up direction in world space
    	DebugPrint(VecStr(up))
    end
    
    

* * *

### TransformToLocalVec 
    
    
    r = TransformToLocalVec(t, v)

Arguments  
t (TTransform) - Transform  
v (TVec) - Vector  


Return value  
r (TVec) - Transformed vector  


Transfom vector v into transform t only considering rotation. 
    
    
    function init()
    	local t = GetBodyTransform(body)
    	local localUp = Vec(0, 1, 0)
    	local up = TransformToParentVec(t, localUp)
    
    	--up now represents the local body up direction in world space
    	DebugPrint(VecStr(up))
    end
    
    

* * *

### TransformToParentPoint 
    
    
    r = TransformToParentPoint(t, p)

Arguments  
t (TTransform) - Transform  
p (TVec) - Vector representing position  


Return value  
r (TVec) - Transformed position  


Transfom position p out of transform t. 
    
    
    function init()
    	local t = GetBodyTransform(body)
    	local bodyPoint = Vec(0, 0, -1)
    	local p = TransformToParentPoint(t, bodyPoint)
    
    	--p now represents the local body point {0, 0, -1 } in world space
    	DebugPrint(VecStr(p))
    end
    
    

* * *

### TransformToLocalPoint 
    
    
    r = TransformToLocalPoint(t, p)

Arguments  
t (TTransform) - Transform  
p (TVec) - Vector representing position  


Return value  
r (TVec) - Transformed position  


Transfom position p into transform t. 
    
    
    function init()
    	local t = GetBodyTransform(body)
    	local worldOrigo = Vec(0, 0, 0)
    	local p = TransformToLocalPoint(t, worldOrigo)
    
    	--p now represents the position of world origo in local body space
    	DebugPrint(VecStr(p))
    end
    
    

* * *

### SetRandomSeed 
    
    
    SetRandomSeed(seed)

Arguments  
seed (number) - Random seed  


Return value  
none
    
    
    function init()
    	SetRandomSeed(42)
    	result = RollDie()
    end
    
    

* * *

### GetRandomBool 
    
    
    result = GetRandomBool()

Arguments  
none

Return value  
result (boolean) - Random true/false  

    
    
    function init()
    	isHeads = GetRandomBool()
    
    	if isHeads then
    		win = true
    	end
    end
    
    

* * *

### GetRandomInt 
    
    
    result = GetRandomInt(min, max)

Arguments  
min (number) - Lower number  
max (number) - Upper number  


Return value  
result (number) - Random number in given range, including max.  

    
    
    function init()
    	dieRoll = GetRandomInt(1,6)
    	-- dieRoll is 1,2,3,4,5 or 6
    end
    
    

* * *

### GetRandomFloat 
    
    
    result = GetRandomFloat(min, max)

Arguments  
min (number) - Lower number  
max (number) - Upper number  


Return value  
result (number) - Random number in given range, including max.  

    
    
    function init()
    	-- Generate a random angle in range [0, 360]
    	randomAngleDeg = GetRandomFloat(0.0f, 360.0f)
    end
    
    

* * *

### GetRandomDirection 
    
    
    vector = GetRandomDirection([length])

Arguments  
length (number, optional) - Optional length use to scale the generated direction.  


Return value  
vector (Vec3) - Random direction with unit length  

    
    
    function init()
    	-- Generate a random direction.
    	ricochetDirection = GetRandomDirection()
    end
    
    

* * *

### FindEntity 
    
    
    handle = FindEntity([tag], [global], [type])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  
type (string, optional) - Entity type ("body", "shape", "light", "location" etc.)  


Return value  
handle (number) - Handle to first entity with specified tag or zero if not found  


Returns an entity with the specified tag and type. This is a universal method that is an alternative to FindBody, FindShape, FindVehicle, etc. 
    
    
    function client.tick()
    	--You may use this function in a similar way to other "Find functions" like FindBody, FindShape, FindVehicle, etc.
    	local myCar = FindEntity("myCar", false, "vehicle")
    
    	--If you do not specify the tag, the first element found will be returned
    	local joint = FindEntity("", true, "joint")
    
    	--If the type is not specified, the search will be performed for all types of entity
    	local target = FindEntity("target", true)
    end
    
    

* * *

### FindEntities 
    
    
    list = FindEntities([tag], [global], [type])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  
type (string, optional) - Entity type ("body", "shape", "light", "location" etc.)  


Return value  
list (table) - Indexed table with handles to all entities with specified tag  


Returns a list of entities with the specified tag and type. This is a universal method that is an alternative to FindBody, FindShape, FindVehicle, etc. 
    
    
    function client.tick()
    	-- You may use this function in a similar way to other "Find functions" like FindBody, FindShape, FindVehicle, etc.
    	local cars = FindEntities("car", false, "vehicle")
    
    	-- You can get all the entities of the specified type by passing an empty string to the tag
    	local allJoints = FindEntities("", true, "joint")
    
    	-- If the type is not specified, the search will be performed for all types
    	local allUnbreakables = FindEntities("unbreakable", true)
    end
    
    

* * *

### GetEntityChildren 
    
    
    list = GetEntityChildren(handle, [tag], [recursive], [type])

Arguments  
handle (number) - Entity handle  
tag (string, optional) - Tag name  
recursive (boolean, optional) - Search recursively  
type (string, optional) - Entity type ("body", "shape", "light", "location" etc.)  


Return value  
list (table) - Indexed table with child elements of the entity  


Returns child entities 
    
    
    function client.tick()
    	local car = FindEntity("car", true, "vehicle")
    	DebugWatch("car", car)
    
    	local children = GetEntityChildren(entity, "", true, "wheel")
    	for i = 1, #children do
    		DebugWatch("wheel " .. tostring(i), children[i])
    	end
    end
    
    

* * *

### GetEntityParent 
    
    
    handle = GetEntityParent(handle, [tag], [type])

Arguments  
handle (number) - Entity handle  
tag (string, optional) - Tag name  
type (string, optional) - Entity type ("body", "shape", "light", "location" etc.)  


Return value  
handle (number) -   

    
    
    function client.tick()
    	local wheel = FindEntity("", true, "wheel")
    	local vehicle = GetEntityParent(wheel,  "", "vehicle")
    	DebugWatch("Wheel vehicle", GetEntityType(vehicle) .. " " .. tostring(vehicle))
    end
    
    

* * *

### SetTag 
    
    
    SetTag(handle, tag, [value])

Arguments  
handle (number) - Entity handle  
tag (string) - Tag name  
value (string, optional) - Tag value  


Return value  
none
    
    
    function init()
    	local handle = FindBody("body", true)
    	--Add "special" tag to an entity
    	SetTag(handle, "special")
    	DebugPrint(HasTag(handle, "special"))
    
    	--Add "team" tag to an entity and give it value "red"
    	SetTag(handle, "team", "red")
    	DebugPrint(HasTag(handle, "team"))
    end
    
    

* * *

### RemoveTag 
    
    
    RemoveTag(handle, tag)

Arguments  
handle (number) - Entity handle  
tag (string) - Tag name  


Return value  
none

Remove tag from an entity. If the tag had a value it is removed too. 
    
    
    function init()
    	local handle = FindBody("body", true)
    	--Add "special" tag to an entity
    	SetTag(handle, "special")
    	RemoveTag(handle, "special")
    	DebugPrint(HasTag(handle, "special"))
    
    	--Add "team" tag to an entity and give it value "red"
    	SetTag(handle, "team", "red")
    	DebugPrint(HasTag(handle, "team"))
    end
    
    

* * *

### HasTag 
    
    
    exists = HasTag(handle, tag)

Arguments  
handle (number) - Entity handle  
tag (string) - Tag name  


Return value  
exists (boolean) - Returns true if entity has tag  

    
    
    function init()
    	local handle = FindBody("body", true)
    	--Add "special" tag to an entity
    	SetTag(handle, "special")
    	DebugPrint(HasTag(handle, "special"))
    
    	--Add "team" tag to an entity and give it value "red"
    	SetTag(handle, "team", "red")
    	DebugPrint(HasTag(handle, "team"))
    end
    
    

* * *

### GetTagValue 
    
    
    value = GetTagValue(handle, tag)

Arguments  
handle (number) - Entity handle  
tag (string) - Tag name  


Return value  
value (string) - Returns the tag value, if any. Empty string otherwise.  

    
    
    function init()
    	local handle = FindBody("body", true)
    
    	--Add "team" tag to an entity and give it value "red"
    	SetTag(handle, "team", "red")
    	DebugPrint(GetTagValue(handle, "team"))
    end
    
    

* * *

### ListTags 
    
    
    tags = ListTags(handle)

Arguments  
handle (number) - Entity handle  


Return value  
tags (table) - Indexed table of tags on entity  

    
    
    function init()
    	local handle = FindBody("body", true)
    
    	--Add "team" tag to an entity and give it value "red"
    	SetTag(handle, "team", "red")
    
    	--List all tags and their tag values for a particular entity
    	local tags = ListTags(handle)
    	for i=1, #tags do
    		DebugPrint(tags[i] .. " " .. GetTagValue(handle, tags[i]))
    	end
    end
    
    

* * *

### GetDescription 
    
    
    description = GetDescription(handle)

Arguments  
handle (number) - Entity handle  


Return value  
description (string) - The description string  


All entities can have an associated description. For bodies and shapes this can be provided through the editor. This function retrieves that description. 
    
    
    function init()
    	local body = FindBody("body", true)
    	DebugPrint(GetDescription(body))
    end
    
    

* * *

### SetDescription 
    
    
    SetDescription(handle, description)

Arguments  
handle (number) - Entity handle  
description (string) - The description string  


Return value  
none

All entities can have an associated description. The description for bodies and shapes will show up on the HUD when looking at them. 
    
    
    function init()
    	local body = FindBody("body", true)
    	SetDescription(body, "Target object")
    	DebugPrint(GetDescription(body))
    end
    
    

* * *

### Delete 
    
    
    Delete(handle)

Arguments  
handle (number) - Entity handle  


Return value  
none

Remove an entity from the scene. All entities owned by this entity will also be removed. 
    
    
    function init()
    	local body = FindBody("body", true)
    	--All shapes associated with body will also be removed
    	Delete(body)
    end
    
    

* * *

### IsHandleValid 
    
    
    exists = IsHandleValid(handle)

Arguments  
handle (number) - Entity handle  


Return value  
exists (boolean) - Returns true if the entity pointed to by handle still exists  

    
    
    function init()
    	local body = FindBody("body", true)
    
    	--valid is true if body still exists
    	DebugPrint(IsHandleValid(body))
    	Delete(body)
    
    	--valid will now be false
    	DebugPrint(IsHandleValid(body))
    end
    
    

* * *

### GetEntityType 
    
    
    type = GetEntityType(handle)

Arguments  
handle (number) - Entity handle  


Return value  
type (string) - Type name of the provided entity  


Returns the type name of provided entity, for example "body", "shape", "light", etc. 
    
    
    function init()
    	local body = FindBody("body", true)
    	DebugPrint(GetEntityType(body))
    end
    
    

* * *

### GetProperty 
    
    
    value = GetProperty(handle, property)

Arguments  
handle (number) - Entity handle  
property (string) - Property name  


Return value  
value (any) - Property value  


 Entity type |  Available params  
---|---  
Body |  desc (string), dynamic (boolean), mass (number), transform, velocity (vector(x, y, z)), angVelocity (vector(x, y, z)), active (boolean), friction (number), restitution (number), frictionMode (average|minimum|multiply|maximum), restitutionMode (average|minimum|multiply|maximum)  
Shape |  density (number), strength (number), size (number), emissiveScale (number), localTransform, worldTransform  
Light |  enabled (boolean), color (vector(r, g, b)), intensity (number), transform, active (boolean), type (string), size (number), reach (number), unshadowed (number), fogscale (number), fogiter (number), glare (number)  
Location |  transform  
Water |  depth (number), wave (number), ripple (number), motion (number), foam (number), color (vector(r, g, b))  
Joint |  type (string), size (number), rotstrength (number), rotspring (number); only for ropes: slack (number), strength (number), maxstretch (number), ropecolor (vector(r, g, b))  
Vehicle |  spring (number), damping (number), topspeed (number), acceleration (number), strength (number), antispin (number), antiroll (number), difflock (number), steerassist (number), friction (number), smokeintensity (number), transform, brokenthreshold (number)  
Wheel |  drive (number), steer (number), travel (vector(x, y))  
Screen |  enabled (boolean), bulge (number), resolution (number, number), script (string), interactive (boolean), emissive (number), fxraster (number), fxca (number), fxnoise (number), fxglitch (number), size (vector(x, y))  
Trigger |  transform, type (string), size (vector(x, y, z)/number)  
      
    
    function client.tick()
    	local body = FindBody("testbody", true)
    	local isDynamic = GetProperty(body, "dynamic")
    	DebugWatch("isDynamic", isDynamic)
    end
    
    

* * *

### SetProperty 
    
    
    SetProperty(handle, property, value)

Arguments  
handle (number) - Entity handle  
property (string) - Property name  
value (any) - Property value  


Return value  
none

 Entity type |  Available params  
---|---  
Body |  desc (string), dynamic (boolean), transform, velocity (vector(x, y, z)), angVelocity (vector(x,y,z)), active (boolean), friction (number), restitution (number), frictionMode (average|minimum|multiply|maximum), restitutionMode (average|minimum|multiply|maximum)  
Shape |  density (number), strength (number), emissiveScale (number), localTransform  
Light |  enabled (boolean), color (vector(r, g, b)), intensity (number), transform, size (number/vector(x,y)), reach (number), unshadowed (number), fogscale (number), fogiter (number), glare (number)  
Location |  transform  
Water |  type (string), depth (number), wave (number), ripple (number), motion (number), foam (number), color (vector(r, g, b))  
Joint |  size (number), rotstrength (number), rotspring (number); only for ropes: slack (number), strength (number), maxstretch (number), color (vector(r, g, b))  
Vehicle |  spring (number), damping (number), topspeed (number), acceleration (number), strength (number), antispin (number), antiroll (number), difflock (number), steerassist (number), friction (number), smokeintensity (number), transform, brokenthreshold (number)  
Wheel |  drive (number), steer (number), travel (vector(x, y))  
Screen |  enabled (boolean), interactive (boolean), emissive (number), fxraster (number), fxca (number), fxnoise (number), fxglitch (number)  
Trigger |  transform, size (vector(x, y, z)/number)  
      
    
    function tick()
    	local light = FindLight("mylight", true)
    	SetProperty(light, "intensity", math.abs(math.sin(GetTime())))
    end
    
    

* * *

### FindBody 
    
    
    handle = FindBody([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
handle (number) - Handle to first body with specified tag or zero if not found  

    
    
    function init()
    	--Search for a body tagged "target" in script scope
    	local target = FindBody("body")
    	DebugPrint(target)
    
    	--Search for a body tagged "escape" in entire scene
    	local escape = FindBody("body", true)
    	DebugPrint(escape)
    end
    
    

* * *

### FindBodies 
    
    
    list = FindBodies([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
list (table) - Indexed table with handles to all bodies with specified tag  

    
    
    function init()
    	--Search for bodies tagged "target" in script scope
    	local targets = FindBodies("target", true)
    	for i=1, #targets do
    		local target = targets[i]
    		DebugPrint(target)
    	end
    end
    
    

* * *

### GetBodyTransform 
    
    
    transform = GetBodyTransform(handle)

Arguments  
handle (number) - Body handle  


Return value  
transform (TTransform) - Transform of the body  

    
    
    function init()
    	local handle = FindBody("target", true)
    	local t = GetBodyTransform(handle)
    	DebugPrint(TransformStr(t))
    end
    
    

* * *

### SetBodyTransform 
    
    
    SetBodyTransform(handle, transform)

Arguments  
handle (number) - Body handle  
transform (TTransform) - Desired transform  


Return value  
none
    
    
    function init()
    	local handle = FindBody("body", true)
    
    	--Move a body 1 meter upwards
    	local t = GetBodyTransform(handle)
    	t.pos = VecAdd(t.pos, Vec(0, 3, 0))
    	SetBodyTransform(handle, t)
    end
    
    

* * *

### GetBodyMass 
    
    
    mass = GetBodyMass(handle)

Arguments  
handle (number) - Body handle  


Return value  
mass (number) - Body mass. Static bodies always return zero mass.  

    
    
    function init()
    	local handle = FindBody("body", true)
    
    	--Move a body 1 meter upwards
    	local mass = GetBodyMass(handle)
    	DebugPrint(mass)
    end
    
    

* * *

### IsBodyDynamic 
    
    
    dynamic = IsBodyDynamic(handle)

Arguments  
handle (number) - Body handle  


Return value  
dynamic (boolean) - Return true if body is dynamic  


Check if body is dynamic. Note that something that was created static may become dynamic due to destruction. 
    
    
    function init()
    	local handle = FindBody("body", true)
    	DebugPrint(IsBodyDynamic(handle))
    end
    
    

* * *

### SetBodyDynamic 
    
    
    SetBodyDynamic(handle, dynamic)

Arguments  
handle (number) - Body handle  
dynamic (boolean) - True for dynamic. False for static.  


Return value  
none

Change the dynamic state of a body. There is very limited use for this function. In most situations you should leave it up to the engine to decide. Use with caution. 
    
    
    function init()
    	local handle = FindBody("body", true)
    	SetBodyDynamic(handle, false)
    	DebugPrint(IsBodyDynamic(handle))
    end
    
    

* * *

### SetBodyVelocity 
    
    
    SetBodyVelocity(handle, velocity)

Arguments  
handle (number) - Body handle (should be a dynamic body)  
velocity (TVec) - Vector with linear velocity  


Return value  
none

This can be used for animating bodies with preserved physical interaction, but in most cases you are better off with a motorized joint instead. 
    
    
    function init()
    	local handle = FindBody("body", true)
    	local vel = Vec(0,10,0)
    	SetBodyVelocity(handle, vel)
    end
    
    

* * *

### GetBodyVelocity 
    
    
    velocity = GetBodyVelocity(handle)

Arguments  
handle (number) - Body handle (should be a dynamic body)  


Return value  
velocity (TVec) - Linear velocity as vector  

    
    
    handle = 0
    function server.init()
    	handle = FindBody("body", true)
    	local vel = Vec(0,10,0)
    	SetBodyVelocity(handle, vel)
    end
    
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	DebugPrint(VecStr(GetBodyVelocity(handle)))
    end
    
    

* * *

### GetBodyVelocityAtPos 
    
    
    velocity = GetBodyVelocityAtPos(handle, pos)

Arguments  
handle (number) - Body handle (should be a dynamic body)  
pos (TVec) - World space point as vector  


Return value  
velocity (TVec) - Linear velocity on body at pos as vector  


Return the velocity on a body taking both linear and angular velocity into account. 
    
    
    handle = 0
    function server.init()
    	handle = FindBody("body", true)
    	local vel = Vec(0,10,0)
    	SetBodyVelocity(handle, vel)
    end
    
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	DebugPrint(VecStr(GetBodyVelocityAtPos(handle, Vec(0, 0, 0))))
    end
    
    

* * *

### SetBodyAngularVelocity 
    
    
    SetBodyAngularVelocity(handle, angVel)

Arguments  
handle (number) - Body handle (should be a dynamic body)  
angVel (TVec) - Vector with angular velocity  


Return value  
none

This can be used for animating bodies with preserved physical interaction, but in most cases you are better off with a motorized joint instead. 
    
    
    function server.init()
    	handle = FindBody("body", true)
    	local angVel = Vec(0,100,0)
    	SetBodyAngularVelocity(handle, angVel)
    end
    
    

* * *

### GetBodyAngularVelocity 
    
    
    angVel = GetBodyAngularVelocity(handle)

Arguments  
handle (number) - Body handle (should be a dynamic body)  


Return value  
angVel (TVec) - Angular velocity as vector  

    
    
    handle = 0
    function server.init()
    	handle = FindBody("body", true)
    	local angVel = Vec(0,100,0)
    	SetBodyAngularVelocity(handle, angVel)
    end
    
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	DebugPrint(VecStr(GetBodyAngularVelocity(handle)))
    end
    
    

* * *

### IsBodyActive 
    
    
    active = IsBodyActive(handle)

Arguments  
handle (number) - Body handle  


Return value  
active (boolean) - Return true if body is active  


Check if body is body is currently simulated. For performance reasons, bodies that don't move are taken out of the simulation. This function can be used to query the active state of a specific body. Only dynamic bodies can be active. 
    
    
    -- try to break the body to see the logs
    function client.tick()
    	handle = FindBody("body", true)
    	if IsBodyActive(handle) then
    		DebugPrint("Body is active")
    	end
    end
    
    

* * *

### SetBodyActive 
    
    
    SetBodyActive(handle, active)

Arguments  
handle (number) - Body handle  
active (boolean) - Set to tru if body should be active (simulated)  


Return value  
none

This function makes it possible to manually activate and deactivate bodies to include or exclude in simulation. The engine normally handles this automatically, so use with care. 
    
    
    handle = 0
    function server.tick()
    	handle = FindBody("body", true)
    
    	-- Forces body to "sleep"
    	SetBodyActive(handle, false)
    end
    
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	handle = FindBody("body", true)
    
    	if IsBodyActive(handle) then
    		DebugPrint("Body is active")
    	end
    end
    
    

* * *

### ApplyBodyImpulse 
    
    
    ApplyBodyImpulse(handle, position, impulse)

Arguments  
handle (number) - Body handle (should be a dynamic body)  
position (TVec) - World space position as vector  
impulse (TVec) - World space impulse as vector  


Return value  
none

Apply impulse to dynamic body at position (give body a push). 
    
    
    function applyImpulse()
    	handle = FindBody("body", true)
    
    	local pos = Vec(0,1,0)
    	local imp = Vec(0,0,10)
    	ApplyBodyImpulse(handle, pos, imp)
    end
    
    

* * *

### GetBodyShapes 
    
    
    list = GetBodyShapes(handle)

Arguments  
handle (number) - Body handle  


Return value  
list (table) - Indexed table of shape handles  


Return handles to all shapes owned by a body 
    
    
    function client.init()
    	handle = FindBody("body", true)
    
    	local shapes = GetBodyShapes(handle)
    	for i=1,#shapes do
    		local shape = shapes[i]
    		DebugPrint(shape)
    	end
    end
    
    

* * *

### GetBodyVehicle 
    
    
    handle = GetBodyVehicle(body)

Arguments  
body (number) - Body handle  


Return value  
handle (number) - Get parent vehicle for body, or zero if not part of vehicle  

    
    
    function client.init()
    	handle = FindBody("body", true)
    
    	local vehicle = GetBodyVehicle(handle)
    	DebugPrint(vehicle)
    end
    
    

* * *

### GetBodyAnimator 
    
    
    handle = GetBodyAnimator(body)

Arguments  
body (number) - Body handle  


Return value  
handle (number) - Get parent animator for body, or zero if not part of an animator hierarchy  

    
    
    local animator = GetBodyAnimator(body)
    
    

* * *

### GetBodyPlayer 
    
    
    playerId = GetBodyPlayer(body)

Arguments  
body (number) - Body handle  


Return value  
playerId (number) - Get parent player for body, or zero if not part of a player animator hierarchy  

    
    
    local player = GetBodyPlayer(body)
    
    

* * *

### GetBodyBounds 
    
    
    min, max = GetBodyBounds(handle)

Arguments  
handle (number) - Body handle  


Return value  
min (TVec) - Vector representing the AABB lower bound  
max (TVec) - Vector representing the AABB upper bound  


Return the world space, axis-aligned bounding box for a body. 
    
    
    function client.init()
    	handle = FindBody("body", true)
    
    	local min, max = GetBodyBounds(handle)
    	local boundsSize = VecSub(max, min)
    	local center = VecLerp(min, max, 0.5)
    	DebugPrint(VecStr(boundsSize) .. " " .. VecStr(center))
    end
    
    

* * *

### GetBodyCenterOfMass 
    
    
    point = GetBodyCenterOfMass(handle)

Arguments  
handle (number) - Body handle  


Return value  
point (TVec) - Vector representing local center of mass in body space  

    
    
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	--Visualize center of mass on for body
    	local com = GetBodyCenterOfMass(handle)
    	local worldPoint = TransformToParentPoint(GetBodyTransform(handle), com)
    	DebugCross(worldPoint)
    end
    
    

* * *

### IsBodyVisible 
    
    
    visible = IsBodyVisible(handle, maxDist, [rejectTransparent], [playerId])

Arguments  
handle (number) - Body handle  
maxDist (number) - Maximum visible distance  
rejectTransparent (boolean, optional) - See through transparent materials. Default false.  
playerId (number, optional) - Player ID. On player, zero means local player.  


Return value  
visible (boolean) - Return true if body is visible  


This function does a very rudimetary check and will only return true if the object is visible within 74 degrees of the camera's forward direction, and only tests line-of-sight visibility for the corners and center of the bounding box. 
    
    
    local handle = 0
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	if IsBodyVisible(handle, 25) then
    		--Body is within 25 meters visible to the camera
    		DebugPrint("visible")
    	else
    		DebugPrint("not visible")
    	end
    end
    
    

* * *

### IsBodyBroken 
    
    
    broken = IsBodyBroken(handle)

Arguments  
handle (number) - Body handle  


Return value  
broken (boolean) - Return true if body is broken  


Determine if any shape of a body has been broken. 
    
    
    local handle = 0
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	DebugPrint(IsBodyBroken(handle))
    end
    
    

* * *

### IsBodyJointedToStatic 
    
    
    result = IsBodyJointedToStatic(handle)

Arguments  
handle (number) - Body handle  


Return value  
result (boolean) - Return true if body is in any way connected to a static body  


Determine if a body is in any way connected to a static object, either by being static itself or be being directly or indirectly jointed to something static. 
    
    
    local handle = 0
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	DebugPrint(IsBodyJointedToStatic(handle))
    end
    
    

* * *

### DrawBodyOutline 
    
    
    DrawBodyOutline(handle, [r], [g], [b], [a])

Arguments  
handle (number) - Body handle  
r (number, optional) - Red  
g (number, optional) - Green  
b (number, optional) - Blue  
a (number, optional) - Alpha  


Return value  
none

Render next frame with an outline around specified body. If no color is given, a white outline will be drawn. 
    
    
    local handle = 0
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	if InputDown("interact") then
    		--Draw white outline at 50% transparency
    		DrawBodyOutline(handle, 0.5)
    	else
    		--Draw green outline, fully opaque
    		DrawBodyOutline(handle, 0, 1, 0, 1)
    	end
    end
    
    

* * *

### DrawBodyHighlight 
    
    
    DrawBodyHighlight(handle, amount)

Arguments  
handle (number) - Body handle  
amount (number) - Amount  


Return value  
none

Flash the appearance of a body when rendering this frame. This is used for valuables in the game. 
    
    
    local handle = 0
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	if InputDown("interact") then
    		DrawBodyHighlight(handle, 0.5)
    	end
    end
    
    

* * *

### GetBodyClosestPoint 
    
    
    hit, point, normal, shape = GetBodyClosestPoint(body, origin)

Arguments  
body (number) - Body handle  
origin (TVec) - World space point  


Return value  
hit (boolean) - True if a point was found  
point (TVec) - World space closest point  
normal (TVec) - World space normal at closest point  
shape (number) - Handle to closest shape  


This will return the closest point of a specific body 
    
    
    local handle = 0
    function client.init()
    	handle = FindBody("body", true)
    end
    
    function client.tick()
    	DebugCross(Vec(1, 0, 0))
    	local hit, p, n, s = GetBodyClosestPoint(handle, Vec(1, 0, 0))
    	if hit then
    		DebugCross(p)
    	end
    end
    
    

* * *

### ConstrainVelocity 
    
    
    ConstrainVelocity(bodyA, bodyB, point, dir, relVel, [min], [max])

Arguments  
bodyA (number) - First body handle (zero for static)  
bodyB (number) - Second body handle (zero for static)  
point (TVec) - World space point  
dir (TVec) - World space direction  
relVel (number) - Desired relative velocity along the provided direction  
min (number, optional) - Minimum impulse (default: -infinity)  
max (number, optional) - Maximum impulse (default: infinity)  


Return value  
none

This will tell the physics solver to constrain the velocity between two bodies. The physics solver will try to reach the desired goal, while not applying an impulse bigger than the min and max values. This function should only be used from the update callback. 
    
    
    local handleA = 0
    local handleB = 0
    function server.init()
    	handleA = FindBody("body", true)
    	handleB = FindBody("target", true)
    end
    
    function server.update()
    	--Constrain the velocity between bodies A and B so that the relative velocity
    	--along the X axis at point (0, 5, 0) is always 3 m/s
    	ConstrainVelocity(handleA, handleB, Vec(0, 5, 0), Vec(1, 0, 0), 3)
    end
    
    

* * *

### ConstrainAngularVelocity 
    
    
    ConstrainAngularVelocity(bodyA, bodyB, dir, relAngVel, [min], [max])

Arguments  
bodyA (number) - First body handle (zero for static)  
bodyB (number) - Second body handle (zero for static)  
dir (TVec) - World space direction  
relAngVel (number) - Desired relative angular velocity along the provided direction  
min (number, optional) - Minimum angular impulse (default: -infinity)  
max (number, optional) - Maximum angular impulse (default: infinity)  


Return value  
none

This will tell the physics solver to constrain the angular velocity between two bodies. The physics solver will try to reach the desired goal, while not applying an angular impulse bigger than the min and max values. This function should only be used from the update callback. 
    
    
    local handleA = 0
    local handleB = 0
    function server.init()
    	handleA = FindBody("body", true)
    	handleB = FindBody("target", true)
    end
    
    function server.update()
    	--Constrain the angular velocity between bodies A and B so that the relative angular velocity
    	--along the Y axis is always 3 rad/s
    	ConstrainAngularVelocity(handleA, handleB, Vec(1, 0, 0), 3)
    end
    
    

* * *

### ConstrainPosition 
    
    
    ConstrainPosition(bodyA, bodyB, pointA, pointB, [maxVel], [maxImpulse])

Arguments  
bodyA (number) - First body handle (zero for static)  
bodyB (number) - Second body handle (zero for static)  
pointA (TVec) - World space point for first body  
pointB (TVec) - World space point for second body  
maxVel (number, optional) - Maximum relative velocity (default: infinite)  
maxImpulse (number, optional) - Maximum impulse (default: infinite)  


Return value  
none

This is a helper function that uses ConstrainVelocity to constrain a point on one body to a point on another body while not affecting the bodies more than the provided maximum relative velocity and maximum impulse. In other words: physically push on the bodies so that pointA and pointB are aligned in world space. This is useful for physically animating objects. This function should only be used from the update callback. 
    
    
    local handleA = 0
    local handleB = 0
    function server.init()
    	handleA = FindBody("body", true)
    	handleB = FindBody("target", true)
    end
    
    function server.update()
    	--Constrain the origo of body a to an animated point in the world
    	local worldPos = Vec(0, 3+math.sin(GetTime()), 0)
    	ConstrainPosition(handleA, 0, GetBodyTransform(handleA).pos, worldPos)
    
    	--Constrain the origo of body a to the origo of body b (like a ball joint)
    	ConstrainPosition(handleA, handleA, GetBodyTransform(handleA).pos, GetBodyTransform(handleB).pos)
    end
    
    

* * *

### ConstrainOrientation 
    
    
    ConstrainOrientation(bodyA, bodyB, quatA, quatB, [maxAngVel], [maxAngImpulse])

Arguments  
bodyA (number) - First body handle (zero for static)  
bodyB (number) - Second body handle (zero for static)  
quatA (TQuat) - World space orientation for first body  
quatB (TQuat) - World space orientation for second body  
maxAngVel (number, optional) - Maximum relative angular velocity (default: infinite)  
maxAngImpulse (number, optional) - Maximum angular impulse (default: infinite)  


Return value  
none

This is the angular counterpart to ConstrainPosition, a helper function that uses ConstrainAngularVelocity to constrain the orientation of one body to the orientation on another body while not affecting the bodies more than the provided maximum relative angular velocity and maximum angular impulse. In other words: physically rotate the bodies so that quatA and quatB are aligned in world space. This is useful for physically animating objects. This function should only be used from the update callback. 
    
    
    local handleA = 0
    local handleB = 0
    function server.init()
    	handleA = FindBody("body", true)
    	handleB = FindBody("target", true)
    end
    
    function server.update()
    	--Constrain the orietation of body a to an upright orientation in the world
    	ConstrainOrientation(handleA, 0, GetBodyTransform(handleA).rot, Quat())
    
    	--Constrain the orientation of body a to the orientation of body b
    	ConstrainOrientation(handleA, handleB, GetBodyTransform(handleA).rot, GetBodyTransform(handleB).rot)
    end
    
    

* * *

### GetWorldBody 
    
    
    body = GetWorldBody()

Arguments  
none

Return value  
body (number) - Handle to the static world body  


Every scene in Teardown has an implicit static world body that contains all shapes that are not explicitly assigned a body in the editor. 
    
    
    local handle
    function client.init()
    	handle = GetWorldBody()
    end
    
    function client.tick()
    	DebugCross(GetBodyTransform(handle).pos)
    end
    
    

* * *

### FindShape 
    
    
    handle = FindShape([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
handle (number) - Handle to first shape with specified tag or zero if not found  

    
    
    local target = 0
    local escape = 0
    function client.init()
    	--Search for a shape tagged "mybox" in script scope
    	target = FindShape("mybox")
    
    	--Search for a shape tagged "laserturret" in entire scene
    	escape = FindShape("laserturret", true)
    end
    
    function client.tick()
    	DebugCross(GetShapeWorldTransform(target).pos)
    	DebugCross(GetShapeWorldTransform(escape).pos)
    end
    
    

* * *

### FindShapes 
    
    
    list = FindShapes([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
list (table) - Indexed table with handles to all shapes with specified tag  

    
    
    local shapes = {}
    function client.init()
    	--Search for shapes tagged "body"
    	shapes = FindShapes("body", true)
    end
    
    function client.tick()
    	for i=1, #shapes do
    		local shape = shapes[i]
    		DebugCross(GetShapeWorldTransform(shape).pos)
    	end
    end
    
    

* * *

### GetShapeLocalTransform 
    
    
    transform = GetShapeLocalTransform(handle)

Arguments  
handle (number) - Shape handle  


Return value  
transform (TTransform) - Return shape transform in body space  

    
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape")
    end
    
    function client.tick()
    	--Shape transform in body local space
    	local shapeTransform = GetShapeLocalTransform(shape)
    
    	--Body transform in world space
    	local bodyTransform = GetBodyTransform(GetShapeBody(shape))
    
    	--Shape transform in world space
    	local worldTranform = TransformToParentTransform(bodyTransform, shapeTransform)
    
    	DebugCross(worldTranform)
    end
    
    

* * *

### SetShapeLocalTransform 
    
    
    SetShapeLocalTransform(handle, transform)

Arguments  
handle (number) - Shape handle  
transform (TTransform) - Shape transform in body space  


Return value  
none
    
    
    local shape = 0
    function server.init()
    	shape = FindShape("shape")
    	local transform = Transform(Vec(0, 1, 0), QuatEuler(0, 90, 0))
    	SetShapeLocalTransform(shape, transform)
    end
    
    function client.init()
    	shape = FindShape("shape")
    end
    
    function client.tick()
    	--Shape transform in body local space
    	local shapeTransform = GetShapeLocalTransform(shape)
    
    	--Body transform in world space
    	local bodyTransform = GetBodyTransform(GetShapeBody(shape))
    
    	--Shape transform in world space
    	local worldTranform = TransformToParentTransform(bodyTransform, shapeTransform)
    
    	DebugCross(worldTranform)
    end
    
    

* * *

### GetShapeWorldTransform 
    
    
    transform = GetShapeWorldTransform(handle)

Arguments  
handle (number) - Shape handle  


Return value  
transform (TTransform) - Return shape transform in world space  


This is a convenience function, transforming the shape out of body space 
    
    
    --GetShapeWorldTransform is equivalent to
    --local shapeTransform = GetShapeLocalTransform(shape)
    --local bodyTransform = GetBodyTransform(GetShapeBody(shape))
    --worldTranform = TransformToParentTransform(bodyTransform, shapeTransform)
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape", true)
    end
    
    function client.tick()
    	DebugCross(GetShapeWorldTransform(shape).pos)
    end
    
    

* * *

### GetShapeBody 
    
    
    handle = GetShapeBody(handle)

Arguments  
handle (number) - Shape handle  


Return value  
handle (number) - Body handle  


Get handle to the body this shape is owned by. A shape is always owned by a body, but can be transfered to a new body during destruction. 
    
    
    local body = 0
    function client.init()
    	body = GetShapeBody(FindShape("shape", true))
    end
    
    function client.tick()
    	DebugCross(GetBodyCenterOfMass(body))
    end
    
    

* * *

### GetShapeJoints 
    
    
    list = GetShapeJoints(shape)

Arguments  
shape (number) - Shape handle  


Return value  
list (table) - Indexed table with joints connected to shape  

    
    
    function printJoints()
    	local shape = FindShape("shape", true)
    
    	local hinges = GetShapeJoints(shape)
    	for i=1, #hinges do
    		local joint = hinges[i]
    		DebugPrint(joint)
    	end
    end
    
    

* * *

### GetShapeLights 
    
    
    list = GetShapeLights(shape)

Arguments  
shape (number) - Shape handle  


Return value  
list (table) - Indexed table of lights owned by shape  

    
    
    function printLights()
    	--Print all lights owned by a shape
    	local shape = FindShape("shape", true)
    
    	local light = GetShapeLights(shape)
    	for i=1, #light do
    		DebugPrint(light[i])
    	end
    end
    
    

* * *

### GetShapeBounds 
    
    
    min, max = GetShapeBounds(handle)

Arguments  
handle (number) - Shape handle  


Return value  
min (TVec) - Vector representing the AABB lower bound  
max (TVec) - Vector representing the AABB upper bound  


Return the world space, axis-aligned bounding box for a shape. 
    
    
    function printShapeBounds()
    	local shape = FindShape("shape", true)
    
    	local min, max = GetShapeBounds(shape)
    	local boundsSize = VecSub(max, min)
    	local center = VecLerp(min, max, 0.5)
    
    	DebugPrint(VecStr(boundsSize) .. " " .. VecStr(center))
    end
    
    

* * *

### SetShapeEmissiveScale 
    
    
    SetShapeEmissiveScale(handle, scale)

Arguments  
handle (number) - Shape handle  
scale (number) - Scale factor for emissiveness  


Return value  
none

Scale emissiveness for shape. If the shape has light sources attached, their intensity will be scaled by the same amount. 
    
    
    local shape = 0
    function server.init()
    	shape = FindShape("shape", true)
    
    	--Pulsate emissiveness and light intensity for shape
    	local scale = math.sin(GetTime())*0.5 + 0.5
    	SetShapeEmissiveScale(shape, scale)
    end
    
    

* * *

### SetShapeDensity 
    
    
    SetShapeDensity(handle, density)

Arguments  
handle (number) - Shape handle  
density (number) - New density for the shape  


Return value  
none

Change the material density of the shape. 
    
    
    local shape = 0
    function server.init()
    	shape = FindShape("shape", true)
    
    	local density = 10.0
    	SetShapeDensity(shape, density)
    end
    
    

* * *

### GetShapeMaterialAtPosition 
    
    
    type, r, g, b, a, entry = GetShapeMaterialAtPosition(handle, pos, [includeUnphysical])

Arguments  
handle (number) - Shape handle  
pos (TVec) - Position in world space  
includeUnphysical (boolean, optional) - Include unphysical voxels in the search. Default false.  


Return value  
type (string) - Material type  
r (number) - Red  
g (number) - Green  
b (number) - Blue  
a (number) - Alpha  
entry (number) - Palette entry for voxel (zero if empty)  


Return material properties for a particular voxel 
    
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape", true)
    end
    
    function client.tick()
    	local pos = GetCameraTransform().pos
    	local dir = Vec(0, 0, 1)
    	local hit, dist, normal, shape = QueryRaycast(pos, dir, 10)
    	if hit then
    		local hitPoint = VecAdd(pos, VecScale(dir, dist))
    		local mat = GetShapeMaterialAtPosition(shape, hitPoint)
    		DebugPrint("Raycast hit voxel made out of " .. mat)
    	end
    	DebugLine(pos, VecAdd(pos, VecScale(dir, 10)))
    end
    
    

* * *

### GetShapeMaterialAtIndex 
    
    
    type, r, g, b, a, entry = GetShapeMaterialAtIndex(handle, x, y, z)

Arguments  
handle (number) - Shape handle  
x (number) - X integer coordinate  
y (number) - Y integer coordinate  
z (number) - Z integer coordinate  


Return value  
type (string) - Material type  
r (number) - Red  
g (number) - Green  
b (number) - Blue  
a (number) - Alpha  
entry (number) - Palette entry for voxel (zero if empty)  


Return material properties for a particular voxel in the voxel grid indexed by integer values. The first index is zero (not one, as opposed to a lot of lua related things) 
    
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape", true)
    	local mat = GetShapeMaterialAtIndex(shape, 0, 0, 0)
    	DebugPrint("The voxel is of material: " .. mat)
    end
    
    

* * *

### GetShapeSize 
    
    
    xsize, ysize, zsize, scale = GetShapeSize(handle)

Arguments  
handle (number) - Shape handle  


Return value  
xsize (number) - Size in voxels along x axis  
ysize (number) - Size in voxels along y axis  
zsize (number) - Size in voxels along z axis  
scale (number) - The size of one voxel in meters (with default scale it is 0.1)  


Return the size of a shape in voxels 
    
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape", true)
    	local x, y, z = GetShapeSize(shape)
    	DebugPrint("Shape size: " .. x .. ";" .. y .. ";" .. z)
    end
    
    

* * *

### GetShapeVoxelCount 
    
    
    count = GetShapeVoxelCount(handle)

Arguments  
handle (number) - Shape handle  


Return value  
count (number) - Number of voxels in shape  


Return the number of voxels in a shape, not including empty space 
    
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape", true)
    	local voxelCount = GetShapeVoxelCount(shape)
    	DebugPrint(voxelCount)
    end
    
    

* * *

### IsShapeVisible 
    
    
    visible = IsShapeVisible(handle, maxDist, [rejectTransparent], [playerId])

Arguments  
handle (number) - Shape handle  
maxDist (number) - Maximum visible distance  
rejectTransparent (boolean, optional) - See through transparent materials. Default false.  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server(host) player.  


Return value  
visible (boolean) - Return true if shape is visible  


This function does a very rudimetary check and will only return true if the object is visible within 74 degrees of the camera's forward direction, and only tests line-of-sight visibility for the corners and center of the bounding box. 
    
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape", true)
    end
    
    function client.tick()
    	if IsShapeVisible(shape, 25) then
    		DebugPrint("Shape is visible")
    	else
    		DebugPrint("Shape is not visible")
    	end
    end
    
    

* * *

### IsShapeBroken 
    
    
    broken = IsShapeBroken(handle)

Arguments  
handle (number) - Shape handle  


Return value  
broken (boolean) - Return true if shape is broken  


Determine if shape has been broken. Note that a shape can be transfered to another body during destruction, but might still not be considered broken if all voxels are intact. 
    
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape", true)
    end
    
    function client.tick()
    	DebugPrint("Is shape broken: " .. tostring(IsShapeBroken(shape)))
    end
    
    

* * *

### DrawShapeOutline 
    
    
    DrawShapeOutline(handle, [r], [g], [b], a)

Arguments  
handle (number) - Shape handle  
r (number, optional) - Red  
g (number, optional) - Green  
b (number, optional) - Blue  
a (number) - Alpha  


Return value  
none

Render next frame with an outline around specified shape. If no color is given, a white outline will be drawn. 
    
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape", true)
    end
    
    function client.tick()
    	if InputDown("interact") then
    		--Draw white outline at 50% transparency
    		DrawShapeOutline(shape, 0.5)
    	else
    		--Draw green outline, fully opaque
    		DrawShapeOutline(shape, 0, 1, 0, 1)
    	end
    end
    
    

* * *

### DrawShapeHighlight 
    
    
    DrawShapeHighlight(handle, amount)

Arguments  
handle (number) - Shape handle  
amount (number) - Amount  


Return value  
none

Flash the appearance of a shape when rendering this frame. 
    
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape", true)
    end
    
    function client.tick()
    	if InputDown("interact") then
    		DrawShapeHighlight(shape, 0.5)
    	end
    end
    
    

* * *

### SetShapeCollisionFilter 
    
    
    SetShapeCollisionFilter(handle, layer, mask)

Arguments  
handle (number) - Shape handle  
layer (number) - Layer bits (0-255)  
mask (number) - Mask bits (0-255)  


Return value  
none

This is used to filter out collisions with other shapes. Each shape can be given a layer bitmask (8 bits, 0-255) along with a mask (also 8 bits). The layer of one object must be in the mask of the other object and vice versa for the collision to be valid. The default layer for all objects is 1 and the default mask is 255 (collide with all layers). 
    
    
    local shapeA = 0
    local shapeB = 0
    local shapeC = 0
    local shapeD = 0
    function server.init()
    	shapeA = FindShape("shapeA")
    	shapeB = FindShape("shapeB")
    	shapeC = FindShape("shapeC")
    	shapeD = FindShape("shapeD")
    	--This will put shapes a and b in layer 2 and disable collisions with
    	--object shapes in layers 2, preventing any collisions between the two.
    	SetShapeCollisionFilter(shapeA, 2, 255-2)
    	SetShapeCollisionFilter(shapeB, 2, 255-2)
    
    	--This will put shapes c and d in layer 4 and allow collisions with other
    	--shapes in layer 4, but ignore all other collisions with the rest of the world.
    	SetShapeCollisionFilter(shapeC, 4, 4)
    	SetShapeCollisionFilter(shapeD, 4, 4)
    end
    
    

* * *

### GetShapeCollisionFilter 
    
    
    layer, mask = GetShapeCollisionFilter(handle)

Arguments  
handle (number) - Shape handle  


Return value  
layer (number) - Layer bits (0-255)  
mask (number) - Mask bits (0-255)  


Returns the current layer/mask settings of the shape 
    
    
    function server.init()
    	local shape = FindShape("some_shape")
    	local layer, mask = GetShapeCollisionFilter(shape)
    end
    
    

* * *

### CreateShape 
    
    
    newShape = CreateShape(body, transform, refShape)

Arguments  
body (number) - Body handle  
transform (TTransform) - Shape transform in body space  
refShape (number or string) - Handle to reference shape or path to vox file  


Return value  
newShape (number) - Handle of new shape  


Create new, empty shape on existing body using the palette of a reference shape. The reference shape can be any existing shape in the scene or an external vox file. The size of the new shape will be 1x1x1. 
    
    
    
    server.tick()
    	local players = GetAllPlayers()
    	for i=1, #players do
    		tickPlayer(players[i])
    	end
    end
    
    function tickPlayer(playerId)
    	if InputPressed("interact", playerId) then
    		local t = Transform(Vec(0, 5, 0), QuatEuler(0, 0, 0))
    		local handle = CreateShape(FindBody("shape", true), t, FindShape("shape", true))
    		DebugPrint(handle)
    	end
    end
    
    

* * *

### ClearShape 
    
    
    ClearShape(shape)

Arguments  
shape (number) - Shape handle  


Return value  
none

Fill a voxel shape with zeroes, thus removing all voxels. 
    
    
    function server.init()
    	ClearShape(FindShape("shape", true))
    end
    
    

* * *

### ResizeShape 
    
    
    resized, offset = ResizeShape(shape, xmi, ymi, zmi, xma, yma, zma)

Arguments  
shape (number) - Shape handle  
xmi (number) - Lower X coordinate  
ymi (number) - Lower Y coordinate  
zmi (number) - Lower Z coordinate  
xma (number) - Upper X coordinate  
yma (number) - Upper Y coordinate  
zma (number) - Upper Z coordinate  


Return value  
resized (boolean) - Resized successfully  
offset (TVec) - Offset vector in shape local space  


Resize an existing shape. The new coordinates are expressed in the existing shape coordinate frame, so you can provide negative values. The existing content is preserved, but may be cropped if needed. The local shape transform will be moved automatically with an offset vector to preserve the original content in body space. This offset vector is returned in shape local space. 
    
    
    function server.init()
    	ResizeShape(FindShape("shape", true), -5, 0, -5, 5, 5, 5)
    end
    
    

* * *

### SetShapeBody 
    
    
    SetShapeBody(shape, body, [transform])

Arguments  
shape (number) - Shape handle  
body (number) - Body handle  
transform (TTransform, optional) - New local shape transform. Default is existing local transform.  


Return value  
none

Move existing shape to a new body, optionally providing a new local transform. 
    
    
    function server.init()
    	SetShapeBody(FindShape("shape", true), FindBody("custombody", true), true)
    end
    
    

* * *

### CopyShapeContent 
    
    
    CopyShapeContent(src, dst)

Arguments  
src (number) - Source shape handle  
dst (number) - Destination shape handle  


Return value  
none

Copy voxel content from source shape to destination shape. If destination shape has a different size, it will be resized to match the source shape. 
    
    
    function server.init()
    	CopyShapeContent(FindShape("shape", true), FindShape("shape2", true))
    end
    
    

* * *

### CopyShapePalette 
    
    
    CopyShapePalette(src, dst)

Arguments  
src (number) - Source shape handle  
dst (number) - Destination shape handle  


Return value  
none

Copy the palette from source shape to destination shape. 
    
    
    function server.init()
    	CopyShapePalette(FindShape("shape", true), FindShape("shape2", true))
    end
    
    

* * *

### GetShapePalette 
    
    
    entries = GetShapePalette(shape)

Arguments  
shape (number) - Shape handle  


Return value  
entries (table) - Palette material entries  


Return list of material entries, each entry is a material index that can be provided to GetShapeMaterial or used as brush for populating a shape. 
    
    
    function server.init()
    	local palette = GetShapePalette(FindShape("shape2", true))
    	for i = 1, #palette do
    		DebugPrint(palette[i])
    	end
    end
    
    

* * *

### GetShapeMaterial 
    
    
    type, red, green, blue, alpha, reflectivity, shininess, metallic, emissive = GetShapeMaterial(shape, entry)

Arguments  
shape (number) - Shape handle  
entry (number) - Material entry  


Return value  
type (string) - Type  
red (number) - Red value  
green (number) - Green value  
blue (number) - Blue value  
alpha (number) - Alpha value  
reflectivity (number) - Range 0 to 1  
shininess (number) - Range 0 to 1  
metallic (number) - Range 0 to 1  
emissive (number) - Range 0 to 32  


Return material properties for specific matirial entry. 
    
    
    function client.init()
    	local type, r, g, b, a, reflectivity, shininess, metallic, emissive = GetShapeMaterial(FindShape("shape2", true), 1)
    	DebugPrint(type)
    end
    
    

* * *

### SetBrush 
    
    
    SetBrush(type, size, index or path, [object])

Arguments  
type (string) - One of "sphere", "cube" or "noise"  
size (number) - Size of brush in voxels (must be in range 1 to 16)  
index or path (number or string) - Material index or path to brush vox file  
object (string, optional) - Optional object in brush vox file if brush vox file is used  


Return value  
none

Set material index to be used for following calls to DrawShapeLine and DrawShapeBox and ExtrudeShape. An optional brush vox file and subobject can be used and provided instead of material index, in which case the content of the brush will be used and repeated. Use material index zero to remove of voxels. 
    
    
    function server.init()
    	SetBrush("sphere", 3, 3)
    end
    
    

* * *

### DrawShapeLine 
    
    
    DrawShapeLine(shape, x0, y0, z0, x1, y1, z1, [paint], [noOverwrite])

Arguments  
shape (number) - Handle to shape  
x0 (number) - Start X coordinate  
y0 (number) - Start Y coordinate  
z0 (number) - Start Z coordinate  
x1 (number) - End X coordinate  
y1 (number) - End Y coordinate  
z1 (number) - End Z coordinate  
paint (boolean, optional) - Paint mode. Default is false.  
noOverwrite (boolean, optional) - Only fill in voxels if space isn't already occupied. Default is false.  


Return value  
none

Draw voxelized line between (x0,y0,z0) and (x1,y1,z1) into shape using the material set up with SetBrush. Paint mode will only change material of existing voxels (where the current material index is non-zero). noOverwrite mode will only fill in voxels if the space isn't already occupied by another shape in the scene. 
    
    
    function server.init()
    	SetBrush("sphere", 3, 1)
    	DrawShapeLine(FindShape("shape"), 0, 0, 0, 10, 50, 5, false, true)
    end
    
    

* * *

### DrawShapeBox 
    
    
    DrawShapeBox(shape, x0, y0, z0, x1, y1, z1)

Arguments  
shape (number) - Handle to shape  
x0 (number) - Start X coordinate  
y0 (number) - Start Y coordinate  
z0 (number) - Start Z coordinate  
x1 (number) - End X coordinate  
y1 (number) - End Y coordinate  
z1 (number) - End Z coordinate  


Return value  
none

Draw box between (x0,y0,z0) and (x1,y1,z1) into shape using the material set up with SetBrush. 
    
    
    function server.init()
    	SetBrush("sphere", 3, 4)
    	DrawShapeBox(FindShape("shape", true), 0, 0, 0, 10, 50, 5)
    end
    
    

* * *

### ExtrudeShape 
    
    
    ExtrudeShape(shape, x, y, z, dx, dy, dz, steps, mode)

Arguments  
shape (number) - Handle to shape  
x (number) - X coordinate to extrude  
y (number) - Y coordinate to extrude  
z (number) - Z coordinate to extrude  
dx (number) - X component of extrude direction, should be -1, 0 or 1  
dy (number) - Y component of extrude direction, should be -1, 0 or 1  
dz (number) - Z component of extrude direction, should be -1, 0 or 1  
steps (number) - Length of extrusion in voxels  
mode (string) - Extrusion mode, one of "exact", "material", "geometry". Default is "exact"  


Return value  
none

Extrude region of shape. The extruded region will be filled in with the material set up with SetBrush. The mode parameter sepcifies how the region is determined. Exact mode selects region of voxels that exactly match the input voxel at input coordinate. Material mode selects region that has the same material type as the input voxel. Geometry mode selects any connected voxel in the same plane as the input voxel. 
    
    
    local shape = 0
    function server.init()
    	SetBrush("sphere", 3, 4)
    	shape = FindShape("shape")
    	ExtrudeShape(shape, 0, 5, 0, -1, 0, 0, 50, "exact")
    end
    
    

* * *

### TrimShape 
    
    
    offset = TrimShape(shape)

Arguments  
shape (number) - Source handle  


Return value  
offset (TVec) - Offset vector in shape local space  


Trim away empty regions of shape, thus potentially making it smaller. If the size of the shape changes, the shape will be automatically moved to preserve the shape content in body space. The offset vector for this translation is returned in shape local space. 
    
    
    local shape = 0
    function server.init()
    	shape = FindShape("shape", true)
    	TrimShape(shape)
    end
    
    

* * *

### SplitShape 
    
    
    newShapes = SplitShape(shape, removeResidual)

Arguments  
shape (number) - Source handle  
removeResidual (boolean) - Remove residual shapes (default false)  


Return value  
newShapes (table) - List of shape handles created  


Split up a shape into multiple shapes based on connectivity. If the removeResidual flag is used, small disconnected chunks will be removed during this process to reduce the number of newly created shapes. 
    
    
    local shape = 0
    function server.init()
    	shape = FindShape("shape", true)
    	SplitShape(shape, true)
    end
    
    

* * *

### MergeShape 
    
    
    shape = MergeShape(shape)

Arguments  
shape (number) - Input shape  


Return value  
shape (number) - Shape handle after merge  


Try to merge shape with a nearby, matching shape. For a merge to happen, the shapes need to be aligned to the same rotation and touching. If the provided shape was merged into another shape, that shape may be resized to fit the merged content. If shape was merged, the handle to the other shape is returned, otherwise the input handle is returned. 
    
    
    local shape = 0
    function server.init()
    	shape = FindShape("shape", true)
    	DebugPrint(shape)
    	shape = MergeShape(shape)
    	DebugPrint(shape)
    end
    
    

* * *

### IsShapeDisconnected 
    
    
    disconnected = IsShapeDisconnected(shape)

Arguments  
shape (number) - Input shape  


Return value  
disconnected (boolean) - True if shape disconnected (has detached parts)  

    
    
    function client.tick()
    	DebugWatch("IsShapeDisconnected", IsShapeDisconnected(FindShape("shape", true)))
    end
    
    

* * *

### IsStaticShapeDetached 
    
    
    disconnected = IsStaticShapeDetached(shape)

Arguments  
shape (number) - Input shape  


Return value  
disconnected (boolean) - True if static shape has detached parts  

    
    
    function client.tick()
    	DebugWatch("IsStaticShapeDetached", IsStaticShapeDetached(FindShape("shape_glass", true)))
    end
    
    

* * *

### GetShapeClosestPoint 
    
    
    hit, point, normal = GetShapeClosestPoint(shape, origin)

Arguments  
shape (number) - Shape handle  
origin (TVec) - World space point  


Return value  
hit (boolean) - True if a point was found  
point (TVec) - World space closest point  
normal (TVec) - World space normal at closest point  


This will return the closest point of a specific shape 
    
    
    local shape = 0
    function client.init()
    	shape = FindShape("shape", true)
    end
    
    function client.tick()
    	DebugCross(Vec(1, 0, 0))
    	local hit, p, n, s = GetShapeClosestPoint(shape, Vec(1, 0, 0))
    	if hit then
    		DebugCross(p)
    	end
    end
    
    

* * *

### IsShapeTouching 
    
    
    touching = IsShapeTouching(a, b)

Arguments  
a (number) - Handle to first shape  
b (number) - Handle to second shape  


Return value  
touching (boolean) - True is shapes a and b are touching each other  


This will check if two shapes has physical overlap 
    
    
    local shapeA = 0
    local shapeB = 0
    function client.init()
    	shapeA = FindShape("shape")
    	shapeB = FindShape("shape2")
    end
    
    function client.tick()
    	DebugPrint(IsShapeTouching(shapeA, shapeB))
    end
    
    

* * *

### FindLocation 
    
    
    handle = FindLocation([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
handle (number) - Handle to first location with specified tag or zero if not found  

    
    
    local loc = 0
    function client.init()
    	loc = FindLocation("loc1")
    end
    
    function client.tick()
    	DebugCross(GetLocationTransform(loc).pos)
    end
    
    

* * *

### FindLocations 
    
    
    list = FindLocations([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
list (table) - Indexed table with handles to all locations with specified tag  

    
    
    local locations
    function client.init()
    	locations = FindLocations("loc1")
    
    	for i=1, #locations do
    		local loc = locations[i]
    		DebugPrint(DebugPrint(loc))
    	end
    end
    
    

* * *

### GetLocationTransform 
    
    
    transform = GetLocationTransform(handle)

Arguments  
handle (number) - Location handle  


Return value  
transform (TTransform) - Transform of the location  

    
    
    local location = 0
    function client.init()
    	location = FindLocation("loc1")
    	DebugPrint(VecStr(GetLocationTransform(location).pos))
    end
    
    

* * *

### FindJoint 
    
    
    handle = FindJoint([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
handle (number) - Handle to first joint with specified tag or zero if not found  

    
    
    function client.init()
    	local joint = FindJoint("doorhinge")
    	DebugPrint(joint)
    end
    
    

* * *

### FindJoints 
    
    
    list = FindJoints([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
list (table) - Indexed table with handles to all joints with specified tag  

    
    
    --Search for locations tagged "doorhinge" in script scope
    function client.init()
    	local hinges = FindJoints("doorhinge")
    	for i=1, #hinges do
    		local joint = hinges[i]
    		DebugPrint(joint)
    	end
    end
    
    

* * *

### IsJointBroken 
    
    
    broken = IsJointBroken(joint)

Arguments  
joint (number) - Joint handle  


Return value  
broken (boolean) - True if joint is broken  

    
    
    function client.init()
    	local broken = IsJointBroken(FindJoint("joint"))
    	DebugPrint(broken)
    end
    
    

* * *

### GetJointType 
    
    
    type = GetJointType(joint)

Arguments  
joint (number) - Joint handle  


Return value  
type (string) - Joint type  


Joint type is one of the following: "ball", "hinge", "prismatic" or "rope". An empty string is returned if joint handle is invalid. 
    
    
    function client.init()
    	local joint = FindJoint("joint")
    	if GetJointType(joint) == "rope" then
    		DebugPrint("Joint is rope")
    	end
    end
    
    

* * *

### GetJointOtherShape 
    
    
    other = GetJointOtherShape(joint, shape)

Arguments  
joint (number) - Joint handle  
shape (number) - Shape handle  


Return value  
other (number) - Other shape handle  


A joint is always connected to two shapes. Use this function if you know one shape and want to find the other one. 
    
    
    function client.init()
    	local joint = FindJoint("joint")
    	--joint is connected to A and B
    
    	otherShape = GetJointOtherShape(joint, FindShape("shapeA"))
    	--otherShape is now B
    
    	otherShape = GetJointOtherShape(joint, FindShape("shapeB"))
    	--otherShape is now A
    end
    
    

* * *

### GetJointShapes 
    
    
    shapes = GetJointShapes(joint)

Arguments  
joint (number) - Joint handle  


Return value  
shapes (number) - Shape handles  


Get shapes connected to the joint. 
    
    
    local mainBody
    local shapes
    local joint
    function server.init()
    	joint = FindJoint("joint")
    	mainBody = GetVehicleBody(FindVehicle("vehicle"))
    	shapes = GetJointShapes(joint)
    end
    
    function server.tick()
    	-- Check to see if joint chain is still connected to vehicle main body
    	-- If not then disable motors
    
    	local connected = false
    	for i=1,#shapes do
    
    		local body = GetShapeBody(shapes[i])
    
    		if body == mainBody then
    			connected = true
    		end
    
    	end
    
    	if connected then
    		SetJointMotor(joint, 0.5)
    	else
    		SetJointMotor(joint, 0.0)
    	end
    end
    
    

* * *

### SetJointMotor 
    
    
    SetJointMotor(joint, velocity, [strength])

Arguments  
joint (number) - Joint handle  
velocity (number) - Desired velocity  
strength (number, optional) - Desired strength. Default is infinite. Zero to disable.  


Return value  
none

Set joint motor target velocity. If joint is of type hinge, velocity is given in radians per second angular velocity. If joint type is prismatic joint velocity is given in meters per second. Calling this function will override and void any previous call to SetJointMotorTarget. 
    
    
    function server.init()
    	--Set motor speed to 0.5 radians per second
    	SetJointMotor(FindJoint("hinge"), 0.5)
    end
    
    

* * *

### SetJointMotorTarget 
    
    
    SetJointMotorTarget(joint, target, [maxVel], [strength])

Arguments  
joint (number) - Joint handle  
target (number) - Desired movement target  
maxVel (number, optional) - Maximum velocity to reach target. Default is infinite.  
strength (number, optional) - Desired strength. Default is infinite. Zero to disable.  


Return value  
none

If a joint has a motor target, it will try to maintain its relative movement. This is very useful for elevators or other animated, jointed mechanisms. If joint is of type hinge, target is an angle in degrees (-180 to 180) and velocity is given in radians per second. If joint type is prismatic, target is given in meters and velocity is given in meters per second. Setting a motor target will override any previous call to SetJointMotor. 
    
    
    function server.init()
    	--Make joint reach a 45 degree angle, going at a maximum of 3 radians per second
    	SetJointMotorTarget(FindJoint("hinge"), 45, 3)
    end
    
    

* * *

### GetJointLimits 
    
    
    min, max = GetJointLimits(joint)

Arguments  
joint (number) - Joint handle  


Return value  
min (number) - Minimum joint limit (angle or distance)  
max (number) - Maximum joint limit (angle or distance)  


Return joint limits for hinge or prismatic joint. Returns angle or distance depending on joint type. 
    
    
    function client.init()
    	local min, max = GetJointLimits(FindJoint("hinge"))
    	DebugPrint(min .. "-" .. max)
    end
    
    

* * *

### GetJointMovement 
    
    
    movement = GetJointMovement(joint)

Arguments  
joint (number) - Joint handle  


Return value  
movement (number) - Current joint position or angle  


Return the current position or angle or the joint, measured in same way as joint limits. 
    
    
    function client.init()
    	local current = GetJointMovement(FindJoint("hinge"))
    	DebugPrint(current)
    end
    
    

* * *

### GetJointedBodies 
    
    
    bodies = GetJointedBodies(body)

Arguments  
body (number) - Body handle (must be dynamic)  


Return value  
bodies (table) - Handles to all dynamic bodies in the jointed structure. The input handle will also be included.  

    
    
    local body = 0
    function client.init()
    	body = FindBody("body")
    end
    
    function client.tick()
    	--Draw outline for all bodies in jointed structure
    	local all = GetJointedBodies(body)
    	for i=1,#all do
    		DrawBodyOutline(all[i], 0.5)
    	end
    end
    
    

* * *

### DetachJointFromShape 
    
    
    DetachJointFromShape(joint, shape)

Arguments  
joint (number) - Joint handle  
shape (number) - Shape handle  


Return value  
none

Detach joint from shape. If joint is not connected to shape, nothing happens. 
    
    
    function server.init()
    	DetachJointFromShape(FindJoint("joint"), FindShape("door"))
    end
    
    

* * *

### GetRopeNumberOfPoints 
    
    
    amount = GetRopeNumberOfPoints(joint)

Arguments  
joint (number) - Joint handle  


Return value  
amount (number) - Number of points in a rope or zero if invalid  


Returns the number of points in the rope given its handle. Will return zero if the handle is not a rope 
    
    
    function client.init()
    	local joint = FindJoint("joint")
    	local numberPoints = GetRopeNumberOfPoints(joint)
    end
    
    

* * *

### GetRopePointPosition 
    
    
    pos = GetRopePointPosition(joint, index)

Arguments  
joint (number) - Joint handle  
index (number) - The point index, starting at 1  


Return value  
pos (TVec) - World position of the point, or nil, if invalid  


Returns the world position of the rope's point. Will return nil if the handle is not a rope or the index is not valid 
    
    
    function client.init()
    	local joint = FindJoint("joint")
    	numberPoints = GetRopeNumberOfPoints(joint)
    
    	for pointIndex = 1, numberPoints do
    		DebugCross(GetRopePointPosition(joint, pointIndex))
    	end
    end
    
    

* * *

### GetRopeBounds 
    
    
    min, max = GetRopeBounds(joint)

Arguments  
joint (number) - Joint handle  


Return value  
min (TVec) - Lower point of rope bounds in world space  
max (TVec) - Upper point of rope bounds in world space  


Returns the bounds of the rope. Will return nil if the handle is not a rope 
    
    
    function client.init()
    	local joint = FindJoint("joint")
    	local mi, ma = GetRopeBounds(joint)
    
    	DebugCross(mi)
    	DebugCross(ma)
    end
    
    

* * *

### BreakRope 
    
    
    BreakRope(joint, point)

Arguments  
joint (number) - Rope type joint handle  
point (TVec) - Point of break as world space vector  


Return value  
none

Breaks the rope at the specified point. 
    
    
    function doPlayerAction(playerId)
    	local playerCameraTransform = GetPlayerCameraTransform(playerId)
    	local dir = TransformToParentVec(playerCameraTransform, Vec(0, 0, -1))
    
    	local hit, dist, joint = QueryRaycastRope(playerCameraTransform.pos, dir, 5)
    	if hit then
    		local breakPoint = VecAdd(playerCameraTransform.pos, VecScale(dir, dist))
    		BreakRope(joint, breakPoint)
    	end
    end
    
    

* * *

### SetAnimatorPositionIK 
    
    
    SetAnimatorPositionIK(handle, begname, endname, target, [weight], [history], [flag])

Arguments  
handle (number) - Animator handle  
begname (string) - Name of the start-bone of the chain  
endname (string) - Name of the end-bone of the chain  
target (TVec) - World target position that the "endname" bone should reach  
weight (number, optional) - Weight [0,1] of this animation, default is 1.0  
history (number, optional) - How much of the previous frames result [0,1] that should be used when start the IK search, default is 0.0  
flag (boolean, optional) - TRUE if constraints should be used, default is TRUE  


Return value  
none
    
    
    SetAnimatorPositionIK(animator, "shoulder_l", "hand_l", Vec(10, 0, 0), 1.0, 0.9, true)
    
    

* * *

### SetAnimatorTransformIK 
    
    
    SetAnimatorTransformIK(handle, begname, endname, transform, [weight], [history], [locktarget], [useconstraints])

Arguments  
handle (number) - Animator handle  
begname (string) - Name of the start-bone of the chain  
endname (string) - Name of the end-bone of the chain  
transform (TTransform) - World target transform that the "endname" bone should reach  
weight (number, optional) - Weight [0,1] of this animation, default is 1.0  
history (number, optional) - How much of the previous frames result [0,1] that should be used when start the IK search, default is 0.0  
locktarget (boolean, optional) - TRUE if the end-bone should be fixed to the target-transform, FALSE if IK solution is used  
useconstraints (boolean, optional) - TRUE if constraints should be used, default is TRUE  


Return value  
none
    
    
    SetAnimatorTransformIK(animator, "shoulder_l", "hand_l", Transform(10, 0, 0), 1.0, 0.9, false, true)
    
    

* * *

### GetBoneChainLength 
    
    
    length = GetBoneChainLength(handle, begname, endname)

Arguments  
handle (number) - Animator handle  
begname (string) - Name of the start-bone of the chain  
endname (string) - Name of the end-bone of the chain  


Return value  
length (number) - Length of the bone chain between "start-bone" and "end-bone"  


This will calculate the length of the bone-chain between the endpoints. If the skeleton have a chain like this (shoulder_l -> upper_arm_l -> lower_arm_l -> hand_l) it will return the length of the upper_arm_l+lower_arm_l 
    
    
    local length = GetBoneChainLength(animator, "shoulder_l", "hand_l")
    
    

* * *

### FindAnimator 
    
    
    handle = FindAnimator([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
handle (number) - Handle to first animator with specified tag or zero if not found  

    
    
    --Search for the first animator in script scope
    local animator = FindAnimator()
    
    --Search for an animator tagged "anim" in script scope
    local animator = FindAnimator("anim")
    
    --Search for an animator tagged "anim2" in entire scene
    local anim2 = FindAnimator("anim2", true)
    
    

* * *

### FindAnimators 
    
    
    list = FindAnimators([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
list (table) - Indexed table with handles to all animators with specified tag  

    
    
    --Search for animators tagged "target" in script scope
    local targets = FindAnimators("target")
    for i=1, #targets do
    	local target = targets[i]
    	...
    end
    
    

* * *

### GetAnimatorTransform 
    
    
    transform = GetAnimatorTransform(handle)

Arguments  
handle (number) - Animator handle  


Return value  
transform (TTransform) - World space transform of the animator  

    
    
    local pos = GetAnimatorTransform(animator).pos
    
    

* * *

### GetAnimatorAdjustTransformIK 
    
    
    transform = GetAnimatorAdjustTransformIK(handle, name)

Arguments  
handle (number) - Animator handle  
name (string) - Name of the location node  


Return value  
transform (TTransform) - World space transform of the animator  


When using IK for a character you can use ik-helpers to define where the 
    
    
    --This will adjust the target transform so that the grip defined by a location node in editor called "ik_hand_l" will reach the target
    local target = Transform(Vec(10, 0, 0), QuatEuler(0, 90, 0))
    local adj = GetAnimatorAdjustTransformIK(animator, "ik_hand_l")
    if adj ~= nil then
        target = TransformToParentTransform(target, adj)
    end
    SetAnimatorTransformIK(animator, "shoulder_l", "hand_l", target, 1.0, 0.9)
    
    

* * *

### SetAnimatorTransform 
    
    
    SetAnimatorTransform(handle, transform)

Arguments  
handle (number) - Animator handle  
transform (TTransform) - Desired transform  


Return value  
none
    
    
    local t = Transform(Vec(10, 0, 0), QuatEuler(0, 90, 0))
    SetAnimatorTransform(animator, t)
    
    

* * *

### MakeRagdoll 
    
    
    MakeRagdoll(handle)

Arguments  
handle (number) - Animator handle  


Return value  
none

Make all prefab bodies physical and leave control to physics system 
    
    
    MakeRagdoll(animator)
    
    

* * *

### UnRagdoll 
    
    
    UnRagdoll(handle, [time])

Arguments  
handle (number) - Animator handle  
time (number, optional) - Transition time  


Return value  
none

Take control if the prefab bodies and do an optional blend between the current ragdoll state and current animation state 
    
    
    --Take control of bodies and do a blend during one sec between the animation state and last physics state
    UnRagdoll(animator, 1.0)
    
    

* * *

### PlayAnimation 
    
    
    handle = PlayAnimation(handle, name, [weight], [filter])

Arguments  
handle (number) - Animator handle  
name (string) - Animation name  
weight (number, optional) - Weight [0,1] of this animation, default is 1.0  
filter (string, optional) - Name of the bone and its subtree that will be affected  


Return value  
handle (number) - Handle to the instance that can be used with PlayAnimationInstance, zero if clip reached its end  


Single animations, one-shot, will be processed after looping animations. 
    
    
    --This will play a single animation "Shooting" with a 80% influence but only on the skeleton starting at bone "Spine"
    PlayAnimation(animator, "Shooting", 0.8, "Spine")
    
    

* * *

### PlayAnimationLoop 
    
    
    PlayAnimationLoop(handle, name, [weight], [filter])

Arguments  
handle (number) - Animator handle  
name (string) - Animation name  
weight (number, optional) - Weight [0,1] of this animation, default is 1.0  
filter (string, optional) - Name of the bone and its subtree that will be affected  


Return value  
none
    
    
    --This will play an animation loop "Walking" with a 100% influence on the whole skeleton
    PlayAnimationLoop(animator, "Walking")
    
    

* * *

### PlayAnimationInstance 
    
    
    handle = PlayAnimationInstance(handle, instance, [weight], [speed])

Arguments  
handle (number) - Animator handle  
instance (number) - Instance handle  
weight (number, optional) - Weight [0,1] of this animation, default is 1.0  
speed (number, optional) - Weight [0,1] of this animation, default is 1.0  


Return value  
handle (number) - Handle to the instance that can be used with PlayAnimationInstance, zero if clip reached its end  


Single animations, one-shot, will be processed after looping animations. 
    
    
    --This will control the weight and speed of the animation thas was initiated by PlayAnimation
    PlayAnimationInstance(animator, handle, 0.8, 1.0)
    
    

* * *

### StopAnimationInstance 
    
    
    StopAnimationInstance(handle, instance)

Arguments  
handle (number) - Animator handle  
instance (number) - Instance handle  


Return value  
none

This will stop the playing anim-instance 

* * *

### PlayAnimationFrame 
    
    
    PlayAnimationFrame(handle, name, time, [weight], [filter])

Arguments  
handle (number) - Animator handle  
name (string) - Animation name  
time (number) - Time in the animation  
weight (number, optional) - Weight [0,1] of this animation, default is 1.0  
filter (string, optional) - Name of the bone and its subtree that will be affected  


Return value  
none
    
    
    --This will play an animation "Walking" at a specific time of 1.5s with a 80% influence on the whole skeleton
    PlayAnimationFrame(animator, "Walking", 1.5, 0.8)
    
    

* * *

### BeginAnimationGroup 
    
    
    BeginAnimationGroup(handle, [weight], [filter])

Arguments  
handle (number) - Animator handle  
weight (number, optional) - Weight [0,1] of this group, default is 1.0  
filter (string, optional) - Name of the bone and its subtree that will be affected  


Return value  
none

You can group looping animations together and use the result of those to blend to target. PlayAnimation will not work here since they are processed last separately from blendgroups. 
    
    
    --This will blend an entire group with 50% influence
    BeginAnimationGroup(animator, 0.5)
    	PlayAnimationLoop(...)
    	PlayAnimationLoop(...)
    EndAnimationGroup(animator)
    
    --You can also create a tree of groups, blending is performed in a depth-first order
    BeginAnimationGroup(animator, 0.5)
    	PlayAnimationLoop(animator, "anim_a", 1.0)
    	PlayAnimationLoop(animator, "anim_b", 0.2)
    	BeginAnimationGroup(animator, 0.75)
    		PlayAnimationLoop(animator, "anim_c", 1.0)
    		PlayAnimationLoop(animator, "anim_d", 0.25)
    	EndAnimationGroup(animator)
    EndAnimationGroup(animator)
    
    

* * *

### EndAnimationGroup 
    
    
    EndAnimationGroup(handle)

Arguments  
handle (number) - Animator handle  


Return value  
none

Ends the group created by BeginAnimationGroup 

* * *

### PlayAnimationInstances 
    
    
    PlayAnimationInstances(handle)

Arguments  
handle (number) - Animator handle  


Return value  
none

Single animations, one-shot, will be processed after looping animations. By calling PlayAnimationInstances you can force it to be processed earlier and be able to "overwrite" the result of it if you want 
    
    
    --First we play a single jump animation affecting the whole skeleton
    --Then we play an aiming animation on the upper-body, filter="Spine1", keeping the lower-body unaffected
    --Then we force the single-animations to be processed, this will force the "jump" to be processed.
    --Then we overwrite just the spine-bone with a mouse controlled rotation("rot")
    --Result will be a jump animation with the upperbody playing an aiming animation but the pitch of the spine controlled by the mouse("rot")
    
    if InputPressed("jump") then
    	PlayAnimation(animator, "Jump")
    end
    PlayAnimationLoop(animator, "Pistol Idle", aimWeight, "Spine1")
    PlayAnimationInstances(animator)
    SetBoneRotation(animator, "Spine1", rot, 1)
    
    

* * *

### GetAnimationClipNames 
    
    
    list = GetAnimationClipNames(handle)

Arguments  
handle (number) - Animator handle  


Return value  
list (table) - Indexed table with animation names  

    
    
    local list = GetAnimationClipNames(animator)
    for i=1, #list do
    	local name = list[i]
    	..
    end
    
    

* * *

### GetAnimationClipDuration 
    
    
    time = GetAnimationClipDuration(handle, name)

Arguments  
handle (number) - Animator handle  
name (string) - Animation name  


Return value  
time (number) - Total duration of the animation  


* * *

### SetAnimationClipFade 
    
    
    SetAnimationClipFade(handle, name, fadein, fadeout)

Arguments  
handle (number) - Animator handle  
name (string) - Animation name  
fadein (number) - Fadein time of the animation  
fadeout (number) - Fadeout time of the animation  


Return value  
none
    
    
    SetAnimationClipFade(animator, "fire", 0.5, 0.5)
    
    

* * *

### SetAnimationClipSpeed 
    
    
    SetAnimationClipSpeed(handle, name, speed)

Arguments  
handle (number) - Animator handle  
name (string) - Animation name  
speed (number) - Sets the speed factor of the animation  


Return value  
none
    
    
    --This will make the clip run 2x as normal speed
    SetAnimationClipSpeed(animator, "walking", 2)
    
    

* * *

### TrimAnimationClip 
    
    
    TrimAnimationClip(handle, name, begoffset, [endoffset])

Arguments  
handle (number) - Animator handle  
name (string) - Animation name  
begoffset (number) - Time offset from the beginning of the animation  
endoffset (number, optional) - Time offset, positive value means from the beginning and negative value means from the end, zero(default) means at end  


Return value  
none
    
    
    --This will "remove" 1s from the beginning and 2s from the end.
    TrimAnimationClip(animator, "walking", 1, -2)
    
    

* * *

### GetAnimationClipLoopPosition 
    
    
    time = GetAnimationClipLoopPosition(handle, name)

Arguments  
handle (number) - Animator handle  
name (string) - Animation name  


Return value  
time (number) - Time of the current playposition in the animation  


* * *

### GetAnimationInstancePosition 
    
    
    time = GetAnimationInstancePosition(handle, instance)

Arguments  
handle (number) - Animator handle  
instance (number) - Instance handle  


Return value  
time (number) - Time of the current playposition in the animation  


* * *

### SetAnimationClipLoopPosition 
    
    
    SetAnimationClipLoopPosition(handle, name, time)

Arguments  
handle (number) - Animator handle  
name (string) - Animation name  
time (number) - Time in the animation  


Return value  
none
    
    
    --This will set the current playposition to one second
    SetAnimationClipLoopPosition(animator, "walking", 1)
    
    

* * *

### SetBoneRotation 
    
    
    SetBoneRotation(handle, name, quat, [weight])

Arguments  
handle (number) - Animator handle  
name (string) - Bone name  
quat (TQuat) - Orientation of the bone  
weight (number, optional) - Weight [0,1] default is 1.0  


Return value  
none
    
    
    --This will set the existing rotation by QuatEuler(...)
    SetBoneRotation(animator, "spine", QuatEuler(0, 180, 0), 1.0)
    
    

* * *

### SetBoneLookAt 
    
    
    SetBoneLookAt(handle, name, point, [weight])

Arguments  
handle (number) - Animator handle  
name (string) - Bone name  
point (table) - World space point as vector  
weight (number, optional) - Weight [0,1] default is 1.0  


Return value  
none
    
    
    --This will set the existing local-rotation to point to world space point
    SetBoneLookAt(animator, "upper_arm_l", Vec(10, 20, 30), 1.0)
    
    

* * *

### RotateBone 
    
    
    RotateBone(handle, name, quat, [weight])

Arguments  
handle (number) - Animator handle  
name (string) - Bone name  
quat (TQuat) - Additive orientation  
weight (number, optional) - Weight [0,1] default is 1.0  


Return value  
none
    
    
    --This will offset the existing rotation by QuatEuler(...)
    RotateBone(animator, "spine", QuatEuler(0, 5, 0), 1.0)
    
    

* * *

### GetBoneNames 
    
    
    list = GetBoneNames(handle)

Arguments  
handle (number) - Animator handle  


Return value  
list (table) - Indexed table with bone-names  

    
    
    local list = GetBoneNames(animator)
    for i=1, #list do
    	local name = list[i]
    	..
    end
    
    

* * *

### GetBoneBody 
    
    
    handle = GetBoneBody(handle, name)

Arguments  
handle (number) - Animator handle  
name (string) - Bone name  


Return value  
handle (number) - Handle to the bone's body, or zero if no bone is present.  

    
    
    local body = GetBoneBody(animator, "head")
    end
    
    

* * *

### GetBoneWorldTransform 
    
    
    transform = GetBoneWorldTransform(handle, name)

Arguments  
handle (number) - Animator handle  
name (string) - Bone name  


Return value  
transform (TTransform) - World space transform of the bone  

    
    
        local animator = GetPlayerAnimator()
        local bones = GetBoneNames(animator)
        for i=1, #bones do
            local bone = bones[i]
            local t = GetBoneWorldTransform(animator,bone)
            DebugCross(t.pos)
        end
    
    

* * *

### GetBoneBindPoseTransform 
    
    
    transform = GetBoneBindPoseTransform(handle, name)

Arguments  
handle (number) - Animator handle  
name (string) - Bone name  


Return value  
transform (TTransform) - Local space transform of the bone in bindpose  

    
    
    local lt = getBindPoseTransform(animator, "lefthand")
    
    

* * *

### FindLight 
    
    
    handle = FindLight([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
handle (number) - Handle to first light with specified tag or zero if not found  

    
    
    function client.init()
    	local light = FindLight("main")
    	DebugPrint(light)
    end
    
    

* * *

### FindLights 
    
    
    list = FindLights([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
list (table) - Indexed table with handles to all lights with specified tag  

    
    
    function client.init()
    	--Search for lights tagged "main" in script scope
    	local lights = FindLights("main")
    	for i=1, #lights do
    		local light = lights[i]
    		DebugPrint(light)
    	end
    end
    
    

* * *

### SetLightEnabled 
    
    
    SetLightEnabled(handle, enabled)

Arguments  
handle (number) - Light handle  
enabled (boolean) - Set to true if light should be enabled  


Return value  
none

If light is owned by a shape, the emissive scale of that shape will be set to 0.0 when light is disabled and 1.0 when light is enabled. 
    
    
    function server.init()
    	SetLightEnabled(FindLight("main"), false)
    end
    
    

* * *

### SetLightColor 
    
    
    SetLightColor(handle, r, g, b)

Arguments  
handle (number) - Light handle  
r (number) - Red value  
g (number) - Green value  
b (number) - Blue value  


Return value  
none

This will only set the color tint of the light. Use SetLightIntensity for brightness. Setting the light color will not affect the emissive color of a parent shape. 
    
    
    function server.init()
    	--Set light color to yellow
    	SetLightColor(FindLight("main"), 1, 1, 0)
    end
    
    

* * *

### SetLightIntensity 
    
    
    SetLightIntensity(handle, intensity)

Arguments  
handle (number) - Light handle  
intensity (number) - Desired intensity of the light  


Return value  
none

If the shape is owned by a shape you most likely want to use SetShapeEmissiveScale instead, which will affect both the emissiveness of the shape and the brightness of the light at the same time. 
    
    
    function server.init()
    	--Pulsate light
    	SetLightIntensity(FindLight("main"), math.sin(GetTime())*0.5 + 1.0)
    end
    
    

* * *

### GetLightTransform 
    
    
    transform = GetLightTransform(handle)

Arguments  
handle (number) - Light handle  


Return value  
transform (TTransform) - World space light transform  


Lights that are owned by a dynamic shape are automatcially moved with that shape 
    
    
    local light = 0
    function client.init()
    	light = FindLight("main")
    	local t = GetLightTransform(light)
    	DebugPrint(VecStr(t.pos))
    end
    
    

* * *

### GetLightShape 
    
    
    handle = GetLightShape(handle)

Arguments  
handle (number) - Light handle  


Return value  
handle (number) - Shape handle or zero if not attached to shape  

    
    
    local light = 0
    function client.init()
    	light = FindLight("main")
    	local shape = GetLightShape(light)
    	DebugPrint(shape)
    end
    
    

* * *

### IsLightActive 
    
    
    active = IsLightActive(handle)

Arguments  
handle (number) - Light handle  


Return value  
active (boolean) - True if light is currently emitting light  

    
    
    local light = 0
    function client.init()
    	light = FindLight("main")
    	if IsLightActive(light) then
    		DebugPrint("Light is active")
    	end
    end
    
    

* * *

### IsPointAffectedByLight 
    
    
    affected = IsPointAffectedByLight(handle, point)

Arguments  
handle (number) - Light handle  
point (TVec) - World space point as vector  


Return value  
affected (boolean) - Return true if point is in light cone and range  

    
    
    local light = 0
    function client.init()
    	light = FindLight("main")
    	local point = Vec(0, 10, 0)
    	local affected = IsPointAffectedByLight(light, point)
    	DebugPrint(affected)
    end
    
    

* * *

### GetFlashlight 
    
    
    handle = GetFlashlight([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
handle (number) - Handle of the player's flashlight  


Returns the handle of the player's flashlight. You can work with it as with an entity of the Light type. 
    
    
    function setFlashlightColor(playerId)
    	local flashlight = GetFlashlight(playerId)
    	SetProperty(flashlight, "color", Vec(0.5, 0, 1))
    end
    
    

* * *

### SetFlashlight 
    
    
    SetFlashlight(handle, [playerId])

Arguments  
handle (number) - Handle of the light  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

Sets a new entity of the Light type as a flashlight. 
    
    
    local oldLight = 0
    function server.tick()
    	... -- some code
    	-- in order not to lose the original flashlight, it is better to save it's handle
    	oldLight = GetFlashlight(playerId)
    	SetFlashlight(FindEntity("mylight", true), playerId)
    end
    
    

* * *

### FindTrigger 
    
    
    handle = FindTrigger([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
handle (number) - Handle to first trigger with specified tag or zero if not found  

    
    
    function server.init()
    	local goal = FindTrigger("goal")
    end
    
    

* * *

### FindTriggers 
    
    
    list = FindTriggers([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
list (table) - Indexed table with handles to all triggers with specified tag  

    
    
    function client.init()
    	--Find triggers tagged "toxic" in script scope
    	local triggers = FindTriggers("toxic")
    	for i=1, #triggers do
    		local trigger = triggers[i]
    		DebugPrint(trigger)
    	end
    end
    
    

* * *

### GetTriggerTransform 
    
    
    transform = GetTriggerTransform(handle)

Arguments  
handle (number) - Trigger handle  


Return value  
transform (TTransform) - Current trigger transform in world space  

    
    
    function client.init()
    	local trigger = FindTrigger("toxic")
    	local t = GetTriggerTransform(trigger)
    	DebugPrint(t.pos)
    end
    
    

* * *

### SetTriggerTransform 
    
    
    SetTriggerTransform(handle, transform)

Arguments  
handle (number) - Trigger handle  
transform (TTransform) - Desired trigger transform in world space  


Return value  
none
    
    
    function server.init()
    	local trigger = FindTrigger("toxic")
    	local t = Transform(Vec(0, 1, 0), QuatEuler(0, 90, 0))
    	SetTriggerTransform(trigger, t)
    end
    
    

* * *

### GetTriggerBounds 
    
    
    min, max = GetTriggerBounds(handle)

Arguments  
handle (number) - Trigger handle  


Return value  
min (TVec) - Lower point of trigger bounds in world space  
max (TVec) - Upper point of trigger bounds in world space  


Return the lower and upper points in world space of the trigger axis aligned bounding box 
    
    
    function client.init()
    	local trigger = FindTrigger("toxic")
    	local mi, ma = GetTriggerBounds(trigger)
    
    	local list = QueryAabbShapes(mi, ma)
    	for i = 1, #list do
    		DebugPrint(list[i])
    	end
    end
    
    

* * *

### IsBodyInTrigger 
    
    
    inside = IsBodyInTrigger(trigger, body)

Arguments  
trigger (number) - Trigger handle  
body (number) - Body handle  


Return value  
inside (boolean) - True if body is in trigger volume  


This function will only check the center point of the body 
    
    
    local trigger = 0
    local body = 0
    function client.init()
    	trigger = FindTrigger("toxic")
    	body = FindBody("body")
    end
    
    function client.tick()
    	if IsBodyInTrigger(trigger, body) then
    		DebugPrint("In trigger!")
    	end
    end
    
    

* * *

### IsVehicleInTrigger 
    
    
    inside = IsVehicleInTrigger(trigger, vehicle)

Arguments  
trigger (number) - Trigger handle  
vehicle (number) - Vehicle handle  


Return value  
inside (boolean) - True if vehicle is in trigger volume  


This function will only check origo of vehicle 
    
    
    local trigger = 0
    local vehicle = 0
    function client.init()
    	trigger = FindTrigger("toxic")
    	vehicle = FindVehicle("vehicle")
    end
    
    function client.tick()
    	if IsVehicleInTrigger(trigger, vehicle) then
    		DebugPrint("In trigger!")
    	end
    end
    
    

* * *

### IsShapeInTrigger 
    
    
    inside = IsShapeInTrigger(trigger, shape)

Arguments  
trigger (number) - Trigger handle  
shape (number) - Shape handle  


Return value  
inside (boolean) - True if shape is in trigger volume  


This function will only check the center point of the shape 
    
    
    local trigger = 0
    local shape = 0
    function client.init()
    	trigger = FindTrigger("toxic")
    	shape = FindShape("shape")
    end
    
    function client.tick()
    	if IsShapeInTrigger(trigger, shape) then
    		DebugPrint("In trigger!")
    	end
    end
    
    

* * *

### IsPointInTrigger 
    
    
    inside = IsPointInTrigger(trigger, point)

Arguments  
trigger (number) - Trigger handle  
point (TVec) - Word space point as vector  


Return value  
inside (boolean) - True if point is in trigger volume  

    
    
    local trigger = 0
    local point = {}
    function client.init()
    	trigger = FindTrigger("toxic", true)
    	point = Vec(0, 0, 0)
    end
    
    function client.tick()
    	if IsPointInTrigger(trigger, point) then
    		DebugPrint("In trigger!")
    	end
    end
    
    

* * *

### IsPointInBoundaries 
    
    
    value, dist = IsPointInBoundaries(point)

Arguments  
point (TVec) - Point  


Return value  
value (boolean) - True if point is inside scene boundaries or if there are no boundaries  
dist (number) - Distance to the scene boundaries. Zero if there are no boundaries or if point is outside.  


Checks whether the point is within the scene boundaries. If there are no boundaries on the scene, the function returns True. 
    
    
    function client.tick()
    	local p = Vec(1.5, 3, 2.5)
    	DebugWatch("In boundaries", IsPointInBoundaries(p))
    end
    
    

* * *

### IsTriggerEmpty 
    
    
    empty, maxpoint = IsTriggerEmpty(handle, [demolision])

Arguments  
handle (number) - Trigger handle  
demolision (boolean, optional) - If true, small debris and vehicles are ignored  


Return value  
empty (boolean) - True if trigger is empty  
maxpoint (TVec) - World space point of highest point (largest Y coordinate) if not empty  


This function will check if trigger is empty. If trigger contains any part of a body it will return false and the highest point as second return value. 
    
    
    local trigger = 0
    function client.init()
    	trigger = FindTrigger("toxic")
    end
    
    function client.tick()
    	local empty, highPoint = IsTriggerEmpty(trigger)
    	if not empty then
    		--highPoint[2] is the tallest point in trigger
    		DebugPrint("Is not empty")
    	end
    end
    
    

* * *

### GetTriggerDistance 
    
    
    distance = GetTriggerDistance(trigger, point)

Arguments  
trigger (number) - Trigger handle  
point (TVec) - Word space point as vector  


Return value  
distance (number) - Positive if point is outside, negative if inside  


Get distance to the surface of trigger volume. Will return negative distance if inside. 
    
    
    local trigger = 0
    function client.init()
    	trigger = FindTrigger("toxic")
    	local p = Vec(0, 10, 0)
    	local dist = GetTriggerDistance(trigger, p)
    	DebugPrint(dist)
    end
    
    

* * *

### GetTriggerClosestPoint 
    
    
    closest = GetTriggerClosestPoint(trigger, point)

Arguments  
trigger (number) - Trigger handle  
point (TVec) - Word space point as vector  


Return value  
closest (TVec) - Closest point in trigger as vector  


Return closest point in trigger volume. Will return the input point itself if inside trigger or closest point on surface of trigger if outside. 
    
    
    local trigger = 0
    function client.init()
    	trigger = FindTrigger("toxic")
    	local p = Vec(0, 10, 0)
    	local closest = GetTriggerClosestPoint(trigger, p)
    	DebugPrint(closest)
    end
    
    

* * *

### FindScreen 
    
    
    handle = FindScreen([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
handle (number) - Handle to first screen with specified tag or zero if not found  

    
    
    function client.init()
    	local screen = FindScreen("tv")
    	DebugPrint(screen)
    end
    
    

* * *

### FindScreens 
    
    
    list = FindScreens([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
list (table) - Indexed table with handles to all screens with specified tag  

    
    
    function client.init()
    	--Find screens tagged "tv" in script scope
    	local screens = FindScreens("tv")
    	for i=1, #screens do
    		local screen = screens[i]
    		DebugPrint(screen)
    	end
    end
    
    

* * *

### SetScreenEnabled SERVER ONLY
    
    
    SetScreenEnabled(screen, enabled)

Arguments  
screen (number) - Screen handle  
enabled (boolean) - True if screen should be enabled  


Return value  
none

Enable or disable screen 
    
    
    function server.init()
    	SetScreenEnabled(FindScreen("tv"), true)
    end
    
    

* * *

### IsScreenEnabled 
    
    
    enabled = IsScreenEnabled(screen)

Arguments  
screen (number) - Screen handle  


Return value  
enabled (boolean) - True if screen is enabled  

    
    
    function client.init()
    	local b = IsScreenEnabled(FindScreen("tv"))
    	DebugPrint(b)
    end
    
    

* * *

### GetScreenShape 
    
    
    shape = GetScreenShape(screen)

Arguments  
screen (number) - Screen handle  


Return value  
shape (number) - Shape handle or zero if none  


Return handle to the parent shape of a screen 
    
    
    local screen = 0
    function client.init()
    	screen = FindScreen("tv")
    	local shape = GetScreenShape(screen)
    	DebugPrint(shape)
    end
    
    

* * *

### GetScreenPlayer 
    
    
    GetScreenPlayer(screen, [playerId])

Arguments  
screen (number) - Screen handle  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

Return playerId that interacts with a screen, or zero if not interacted with 
    
    
    local player = GetScreenPlayer(screen)
    
    

* * *

### FindVehicle 
    
    
    handle = FindVehicle([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
handle (number) - Handle to first vehicle with specified tag or zero if not found  

    
    
    function client.init()
    	local vehicle = FindVehicle("mycar")
    end
    
    

* * *

### FindVehicles 
    
    
    list = FindVehicles([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
list (table) - Indexed table with handles to all vehicles with specified tag  

    
    
    function client.init()
    	--Find all vehicles in level tagged "boat"
    	local boats = FindVehicles("boat")
    	for i=1, #boats do
    		local boat = boats[i]
    		DebugPrint(boat)
    	end
    end
    
    

* * *

### GetVehicleTransform 
    
    
    transform = GetVehicleTransform(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
transform (TTransform) - Transform of vehicle  

    
    
    function client.init()
    	local vehicle = FindVehicle("vehicle")
    	local t = GetVehicleTransform(vehicle)
    end
    
    

* * *

### GetVehicleExhaustTransforms 
    
    
    transforms = GetVehicleExhaustTransforms(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
transforms (table) - Transforms of vehicle exhausts  


Returns the exhausts transforms in local space of the vehicle. 
    
    
    function client.tick()
    	local vehicle = FindVehicle("car", true)
    	local t = GetVehicleExhaustTransforms(vehicle)
    	for i = 1, #t do
    		DebugWatch(tostring(i), t[i])
    	end
    end
    
    

* * *

### GetVehicleVitalTransforms 
    
    
    transforms = GetVehicleVitalTransforms(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
transforms (table) - Transforms of vehicle vitals  


Returns the vitals transforms in local space of the vehicle. 
    
    
    function client.tick()
    	local vehicle = FindVehicle("car", true)
    	local t = GetVehicleVitalTransforms(vehicle)
    	for i = 1, #t do
    		DebugWatch(tostring(i), t[i])
    	end
    end
    
    

* * *

### GetVehicleBodies 
    
    
    transforms = GetVehicleBodies(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
transforms (table) - Vehicle bodies handles  

    
    
    function client.tick()
    	local vehicle = FindVehicle("car", true)
    	local t = GetVehicleBodies(vehicle)
    	for i = 1, #t do
    		DebugWatch(tostring(i), t[i])
    	end
    end
    
    

* * *

### GetVehicleBody 
    
    
    body = GetVehicleBody(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
body (number) - Main body of vehicle  

    
    
    function client.init()
    	local vehicle = FindVehicle("vehicle")
    	local body = GetVehicleBody(vehicle)
    	if IsBodyBroken(body) then
    		DebugPrint("Is broken")
    	end
    end
    
    

* * *

### GetVehicleHealth 
    
    
    health = GetVehicleHealth(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
health (number) - Vehicle health (zero to one)  

    
    
    function client.init()
    	local vehicle = FindVehicle("vehicle")
    	local health = GetVehicleHealth(vehicle)
    	DebugPrint(health)
    end
    
    

* * *

### GetVehicleParams 
    
    
    params = GetVehicleParams(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
params (table) - Vehicle params  

    
    
    function client.tick()
    	local params = GetVehicleParams(FindVehicle("car", true))
    	for key, value in pairs(params) do
    		DebugWatch(key, value)
    	end
    end
    
    

* * *

### SetVehicleParam SERVER ONLY
    
    
    SetVehicleParam(handle, param, value)

Arguments  
handle (number) - Vehicle handler  
param (string) - Param name  
value (number) - Param value  


Return value  
none

Available parameters: spring, damping, topspeed, acceleration, strength, antispin, antiroll, difflock, steerassist, friction 
    
    
    function server.init()
    	SetVehicleParam(FindVehicle("car", true), "topspeed", 200)
    end
    
    

* * *

### GetVehicleDriverPos 
    
    
    pos = GetVehicleDriverPos(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
pos (TVec) - Driver position as vector in vehicle space  

    
    
    function client.init()
    	local vehicle = FindVehicle("vehicle")
    	local driverPos = GetVehicleDriverPos(vehicle)
    	local t = GetVehicleTransform(vehicle)
    	local worldPos = TransformToParentPoint(t, driverPos)
    	DebugPrint(worldPos)
    end
    
    

* * *

### GetVehicleAvailableSeatPos 
    
    
    pos = GetVehicleAvailableSeatPos(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
pos (TVec) - World space position of the next available seat. {0, 0, 0} if none is available.  

    
    
    function client.tick()
    	local vehicle = FindVehicle("vehicle")
    	local pos = GetVehicleAvailableSeatPos(vehicle)
    	DebugPrint(pos)
    end
    
    

* * *

### GetVehicleSteering 
    
    
    steering = GetVehicleSteering(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
steering (number) - Driver steering value -1 to 1  

    
    
    local steering = GetVehicleSteering(vehicle)
    
    

* * *

### GetVehicleDrive 
    
    
    drive = GetVehicleDrive(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
drive (number) - Driver drive value -1 to 1  

    
    
    local drive = GetVehicleDrive(vehicle)
    
    

* * *

### DriveVehicle SERVER ONLY
    
    
    DriveVehicle(vehicle, drive, steering, handbrake)

Arguments  
vehicle (number) - Vehicle handle  
drive (number) - Reverse/forward control -1 to 1  
steering (number) - Left/right control -1 to 1  
handbrake (boolean) - Handbrake control  


Return value  
none

This function applies input to vehicles, allowing for autonomous driving. The vehicle will be turned on automatically and turned off when no longer called. Call this from the tick function, not update. 
    
    
    function server.tick()
    	--Drive mycar forwards
    	local v = FindVehicle("mycar")
    	DriveVehicle(v, 1, 0, false)
    end
    
    

* * *

### GetVehicleLocationWorldTransform 
    
    
    transform = GetVehicleLocationWorldTransform(vehicle, name)

Arguments  
vehicle (number) - Vehicle handle  
name (string) - Name of location  


Return value  
transform (TTransform) - World transform  

    
    
    local t = GetVehicleLocationWorldTransform(vehicle, "player_steeringwheel")
    
    

* * *

### GetVehiclePassengerCount 
    
    
    count, seats, hasDriver = GetVehiclePassengerCount(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
count (number) - Number of passengers  
seats (number) - Number of seats  
hasDriver (bool) - If vehicle has a driver  

    
    
    local passengers, seats, hasDriver = GetVehiclePassengerCount(vehicle)
    
    

* * *

### SetVehicleHealth SERVER ONLY
    
    
    SetVehicleHealth(vehicle, health)

Arguments  
vehicle (number) - Vehicle handle  
health (number) - Set vehicle health (between zero and one)  


Return value  
none

Works only for vehicles with 'customhealth' tag. 'customhealth' disables the common vehicles damage system. So this function needed for custom vehicle damage systems. 
    
    
    function server.tick()
    	if InputPressed("usetool", playerId) then
    		SetVehicleHealth(FindVehicle("car", true), 0.0)
    	end
    end
    
    

* * *

### FindRig 
    
    
    handle = FindRig([tag], [global])

Arguments  
tag (string, optional) - Tag name  
global (boolean, optional) - Search in entire scene  


Return value  
handle (number) - Handle to first rig with specified tag or zero if not found  

    
    
    function client.init()
    	local rig = FindRig("myrig")
    end
    
    

* * *

### GetRigWorldTransform 
    
    
    transform = GetRigWorldTransform(rig)

Arguments  
rig (number) - Rig handle  


Return value  
transform (TTransform) - World transform, nil if rig is missing  

    
    
        local t = GetRigWorldTransform(rig)
    
    

* * *

### SetRigWorldTransform 
    
    
    SetRigWorldTransform(rig, transform)

Arguments  
rig (number) - Rig handle  
transform (TTransform) - New world transform  


Return value  
none
    
    
        SetRigWorldTransform(rig, Transform(...))
    
    

* * *

### GetRigLocationWorldTransform 
    
    
    transform = GetRigLocationWorldTransform(rig, name)

Arguments  
rig (number) - Rig handle  
name (string) - Name of location  


Return value  
transform (TTransform) - World transform, nil if rig is missing or location is missing  

    
    
    local foot_t = GetRigLocationWorldTransform(rigid, "ik_foot_l")
    
    

* * *

### SetRigLocationWorldTransform 
    
    
    SetRigLocationWorldTransform(rig, name, transform)

Arguments  
rig (number) - Rig handle  
name (string) - Name of location  
transform (TTransform) - New world transform  


Return value  
none
    
    
        SetRigLocationWorldTransform(rig, "some_location_name", Transform(...))
    
    

* * *

### GetRigLocationLocalTransform 
    
    
    transform = GetRigLocationLocalTransform(rig, name)

Arguments  
rig (number) - Rig handle  
name (string) - Name of location  


Return value  
transform (TTransform) - Local transform, nil if rig is missing or location is missing  

    
    
    local t = GetRigLocationLocalTransform(rigid, "some_location_name")
    
    

* * *

### SetRigLocationLocalTransform 
    
    
    SetRigLocationLocalTransform(rig, name, transform)

Arguments  
rig (number) - Rig handle  
name (string) - Name of location  
transform (TTransform) - New world transform  


Return value  
none
    
    
        local someBody = FindBody("bodyname")
        SetPlayerRigTransform(someBody, GetBodyTransform(someBody))
    
    

* * *

### GetAllPlayers 
    
    
    name = GetAllPlayers()

Arguments  
none

Return value  
name (list) - List of all player Ids  

    
    
    local playerIds = GetAllPlayers()
    
    

* * *

### GetMaxPlayers 
    
    
    count = GetMaxPlayers()

Arguments  
none

Return value  
count (interger) - Number of max players for the session. Returns 1 for non-multiplayer.  

    
    
    local maxPlayerCount = GetMaxPlayers()
    -- create an UI big enough to fit a the max player count
    createGameModeUI(maxPlayerCount)
    
    

* * *

### GetPlayerCount 
    
    
    count = GetPlayerCount()

Arguments  
none

Return value  
count (number) - Number of players  

    
    
    local playerCount = GetPlayerCount()
    
    

* * *

### GetAddedPlayers 
    
    
    playerIds = GetAddedPlayers()

Arguments  
none

Return value  
playerIds (table) - List of added player Ids  

    
    
    local playerIds = GetAddedPlayers()
    
    

* * *

### GetRemovedPlayers 
    
    
    playerIds = GetRemovedPlayers()

Arguments  
none

Return value  
playerIds (table) - List of removed player Ids  

    
    
    local playerIds = GetRemovedPlayers()
    
    

* * *

### GetPlayerName 
    
    
    name = GetPlayerName([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
name (string) - Player name  

    
    
    local name = GetPlayerName(0)
    
    

* * *

### GetLocalPlayer 
    
    
    GetLocalPlayer = GetLocalPlayer()

Arguments  
none

Return value  
GetLocalPlayer (number) - Local player ID.  

    
    
    local p = GetLocalPlayer()
    
    

* * *

### IsPlayerLocal 
    
    
    IsPlayerLocal = IsPlayerLocal([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
IsPlayerLocal (boolean) - Whether a player is the local player.  

    
    
    if IsPlayerLocal(attacker) then
    	score = score + 1
    end
    
    

* * *

### GetPlayerCharacter 
    
    
    character = GetPlayerCharacter([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
character (string) - Character id  

    
    
    local character = GetPlayerCharacter(0)
    
    

* * *

### IsPlayerHost 
    
    
    IsPlayerHost = IsPlayerHost([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
IsPlayerHost (boolean) - Whether a player is the host  

    
    
    local isHost = IsPlayerHost()
    
    

* * *

### IsPlayerValid 
    
    
    IsPlayerValid = IsPlayerValid([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
IsPlayerValid (boolean) - Whether a player is valid (existing player)  

    
    
    local isValid = IsPlayerValid(flagCarrier)
    if not isValid then
    	dropFlag()
    end
    
    

* * *

### GetPlayerPos 
    
    
    position = GetPlayerPos([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
position (TVec) - Player center position  


Return center point of player. This function is deprecated. Use GetPlayerTransform instead. 
    
    
    function client.init()
    	local p = GetPlayerPos()
    	DebugPrint(p)
    
    	--This is equivalent to
    	p = VecAdd(GetPlayerTransform().pos, Vec(0,1,0))
    	DebugPrint(p)
    end
    
    

* * *

### GetPlayerAimInfo 
    
    
    hit, startpos, endpos, direction, hitnormal, hitdist, hitentity, hitmaterial = GetPlayerAimInfo(position, [maxdist], [playerId])

Arguments  
position (TVec) - Start position of the search  
maxdist (number, optional) - Max search distance  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
hit (boolean) - TRUE if hit, FALSE otherwise.  
startpos (TVec) - Player can modify start position when close to walls etc  
endpos (TVec) - Hit position  
direction (TVec) - Direction from start position to end position  
hitnormal (TVec) - Normal of the hitpoint  
hitdist (number) - Distance of the hit  
hitentity (handle) - Handle of the entitiy being hit  
hitmaterial (handle) - Name of the material being hit  

    
    
    local muzzle = GetToolLocationWorldTransform("muzzle")
    local _, pos, _, dir = GetPlayerAimInfo(muzzle.pos)
    Shoot(pos, dir)
    
    

* * *

### GetPlayerPitch 
    
    
    pitch = GetPlayerPitch([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
pitch (number) - Current player pitch angle  


The player pitch angle is applied to the player camera transform. This value can be used to animate tool pitch movement when using SetToolTransformOverride. 
    
    
    function client.init()
    	local pitchRotation = Quat(Vec(1,0,0), GetPlayerPitch())
    end
    
    

* * *

### GetPlayerYaw 
    
    
    yaw = GetPlayerYaw([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
yaw (number) - Current player yaw angle  


The player yaw angle is applied to the player camera transform. It represents the top-down angle of rotation of the player. 
    
    
    function client.init()
    	local compassBearing = GetPlayerYaw()
    end
    
    

* * *

### SetPlayerPitch SERVER ONLY
    
    
    SetPlayerPitch(pitch, [playerId])

Arguments  
pitch (number) - Pitch.  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

Sets the player pitch. 
    
    
    function server.tick()
    	-- look straight ahead
    	SetPlayerPitch(0.0, playerId)
    end
    
    

* * *

### GetPlayerCrouch 
    
    
    recoil = GetPlayerCrouch([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
recoil (number) - Current player crouch  

    
    
    function client.tick()
        local crouch = GetPlayerCrouch()
        if crouch > 0.0 then
            ...
        end
    end
    
    

* * *

### GetPlayerTransform 
    
    
    transform = GetPlayerTransform([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
transform (TTransform) - Current player transform  


The player transform is located at the bottom of the player. The player transform considers heading (looking left and right). Forward is along negative Z axis. Player pitch (looking up and down) does not affect player transform. If you want the transform of the eye, use GetPlayerCameraTransform() instead. 
    
    
    function client.init()
    	local t = GetPlayerTransform()
    	DebugPrint(TransformStr(t))
    end
    
    

* * *

### GetPlayerTransformWithPitch 
    
    
    transform = GetPlayerTransformWithPitch([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
transform (table) - Current player transform, including pitch (look up/down)  


The player transform is located at the bottom of the player. Forward is along negative Z axis. If you want the transform of the eye, use GetPlayerCameraTransform() instead. 
    
    
    local t = GetPlayerTransform()
    
    

* * *

### SetPlayerTransform SERVER ONLY
    
    
    SetPlayerTransform(transform, [playerId])

Arguments  
transform (TTransform) - Desired player transform  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Instantly teleport the player to desired transform, excluding pitch. If you want to include pitch, use SetPlayerTransformWithPitch instead. Player velocity will be reset to zero. 
    
    
    function server.tick()
    	if InputPressed("jump", playerId) then
    		local t = Transform(Vec(50, 0, 0), QuatEuler(0, 90, 0))
    		SetPlayerTransform(t, playerId)
    	end
    end
    
    

* * *

### SetPlayerTransformWithPitch SERVER ONLY
    
    
    SetPlayerTransformWithPitch(transform, [playerId])

Arguments  
transform (table) - Desired player transform  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Instantly teleport the player to desired transform, including pitch. Player velocity will be reset to zero. 
    
    
    local t = Transform(Vec(10, 0, 0), QuatEuler(30, 90, 0))
    SetPlayerTransform(t, playerId)
    
    

* * *

### SetPlayerGroundVelocity SERVER ONLY
    
    
    SetPlayerGroundVelocity(vel, [playerId])

Arguments  
vel (TVec) - Desired ground velocity  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Make the ground act as a conveyor belt, pushing the player even if ground shape is static. 
    
    
    function server.tick()
    	SetPlayerGroundVelocity(Vec(2,0,0), playerId)
    end
    
    

* * *

### GetPlayerEyeTransform 
    
    
    transform = GetPlayerEyeTransform([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
transform (TTransform) - Current player eye transform  


The player eye transform is the same as what you get from GetCameraTransform when playing in first-person, but if you have set a camera transform manually with SetCameraTransform or playing in third-person, you can retrieve the player eye transform with this function. 
    
    
    function client.init()
    	local t = GetPlayerEyeTransform()
    	DebugPrint(TransformStr(t))
    end
    
    

* * *

### GetPlayerCameraTransform 
    
    
    transform = GetPlayerCameraTransform([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
transform (TTransform) - Current player camera transform  


The player camera transform is usually the same as what you get from GetCameraTransform, but if you have set a camera transform manually with SetCameraTransform, you can retrieve the standard player camera transform with this function. 
    
    
    function client.init()
    	local t = GetPlayerCameraTransform()
    	DebugPrint(TransformStr(t))
    end
    
    

* * *

### SetPlayerCameraOffsetTransform CLIENT ONLY
    
    
    SetPlayerCameraOffsetTransform(transform, [stackable], [playerId])

Arguments  
transform (TTransform) - Desired player camera offset transform  
stackable (boolean, optional) - True if eye offset should summ up with multiple calls per tick  
playerId (number, optional) - Player ID. On client, zero means client player.  


Return value  
none

Call this function continously to apply a camera offset. Can be used for camera effects such as shake and wobble. 
    
    
    function client.tick()
    	local t = Transform(Vec(), QuatAxisAngle(Vec(1, 0, 0), math.sin(GetTime()*3.0) * 3.0))
    	SetPlayerCameraOffsetTransform(t, playerId)
    end
    
    

* * *

### SetPlayerSpawnTransform SERVER ONLY
    
    
    SetPlayerSpawnTransform(transform, [playerId])

Arguments  
transform (TTransform) - Desired player spawn transform  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Call this function during init to alter the player spawn transform. 
    
    
    function setPlayerSpawnTransform(playerId)
    	local t = Transform(Vec(10, 0, 0), QuatEuler(0, 90, 0))
    	SetPlayerSpawnTransform(t, playerId)
    end
    
    

* * *

### SetPlayerSpawnHealth SERVER ONLY
    
    
    SetPlayerSpawnHealth(health, [playerId])

Arguments  
health (number) - Desired player spawn health (between zero and one)  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Call this function during init to alter the player spawn health amount. 
    
    
    function playerJoined(playerId)
    	SetPlayerSpawnHealth(0.5, playerId)
    end
    
    

* * *

### SetPlayerSpawnTool SERVER ONLY
    
    
    SetPlayerSpawnTool(id, [playerId])

Arguments  
id (string) - Tool unique identifier  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Call this function during init to alter the player spawn active tool. 
    
    
    function playerJoined(playerId)
    	SetPlayerSpawnTool("pistol", playerId)
    end
    
    

* * *

### GetPlayerVelocity 
    
    
    velocity = GetPlayerVelocity([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
velocity (TVec) - Player velocity in world space as vector  

    
    
    function client.tick()
    	local vel = GetPlayerVelocity()
    	DebugPrint(VecStr(vel))
    end
    
    

* * *

### SetPlayerVehicle SERVER ONLY
    
    
    SetPlayerVehicle(vehicle, [playerId])

Arguments  
vehicle (number) - Handle to vehicle or zero to not drive.  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Drive specified vehicle. 
    
    
    function server.tick()
    	if InputPressed("interact", playerId) then
    		local car = FindVehicle("mycar")
    		SetPlayerVehicle(car, playerId)
    	end
    end
    
    

* * *

### SetPlayerAnimator 
    
    
    SetPlayerAnimator(animator, [playerId])

Arguments  
animator (number) - Handle to animator or zero for no animator  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

* * *

### GetPlayerAnimator 
    
    
    animator = GetPlayerAnimator([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
animator (number) - Handle to animator or zero for no animator  


* * *

### GetPlayerBodies 
    
    
    bodies = GetPlayerBodies([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
bodies (list) - Get bodies associated with a player  

    
    
    local bodies = GetPlayerBodies(playerId)
    
    

* * *

### SetPlayerVelocity SERVER ONLY
    
    
    SetPlayerVelocity(velocity, [playerId])

Arguments  
velocity (TVec) - Player velocity in world space as vector  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none
    
    
    function server.tick()
    	if InputPressed("jump", playerId) then
    		SetPlayerVelocity(Vec(0, 5, 0), playerId)
    	end
    end
    
    

* * *

### GetPlayerVehicle 
    
    
    handle = GetPlayerVehicle([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
handle (number) - Current vehicle handle, or zero if not in vehicle  

    
    
    function client.tick()
    	local vehicle = GetPlayerVehicle()
    	if vehicle ~= 0 then
    		DebugPrint("Player drives the vehicle")
    	end
    end
    
    

* * *

### IsPlayerGrounded 
    
    
    isGrounded = IsPlayerGrounded([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
isGrounded (boolean) - Whether the player is grounded  

    
    
    local isGrounded = IsPlayerGrounded()
    
    

* * *

### IsPlayerVehicleDriver 
    
    
    isDriver = IsPlayerVehicleDriver(handle, [playerId])

Arguments  
handle (number) - Vehicle handle  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
isDriver (boolean) - Whether the player is driver for this vehicle  

    
    
    local vehicle = FindVehicle("myvehicle")
    local isDriver = IsPlayerVehicleDriver(vehicle)
    
    

* * *

### IsPlayerVehiclePassenger 
    
    
    isPassenger = IsPlayerVehiclePassenger(handle, [playerId])

Arguments  
handle (number) - Vehicle handle  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
isPassenger (boolean) - Whether the player is a passenger of this vehicle  

    
    
    local vehicle = FindVehicle("myvehicle")
    local isPassenger = IsPlayerVehiclePassenger(vehicle)
    
    

* * *

### IsPlayerJumping 
    
    
    isGrounded = IsPlayerJumping([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
isGrounded (boolean) - Whether the player is jumping or not  

    
    
    local isJumping = IsPlayerJumping()
    
    

* * *

### GetPlayerGroundContact 
    
    
    contact, shape, point, normal = GetPlayerGroundContact([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
contact (boolean) - Whether the player is grounded  
shape (number) - Handle to shape  
point (Vec) - Point of contact  
normal (Vec) - Normal of contact  


Get information about player ground contact. If the output boolean (contact) is false then the rest of the output is invalid. 
    
    
    function client.tick()
    	hasGroundContact, shape, point, normal = GetPlayerGroundContact()
    
    	if hasGroundContact then
    		-- print ground contact data
    		DebugPrint(VecStr(point).." : "..VecStr(normal))
    	end
    end
    
    

* * *

### GetPlayerGrabShape 
    
    
    handle = GetPlayerGrabShape([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
handle (number) - Handle to grabbed shape or zero if not grabbing.  

    
    
    function client.tick()
    	local shape = GetPlayerGrabShape()
    	if shape ~= 0 then
    		DebugPrint("Player is grabbing a shape")
    	end
    end
    
    

* * *

### GetPlayerGrabBody 
    
    
    handle = GetPlayerGrabBody([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
handle (number) - Handle to grabbed body or zero if not grabbing.  

    
    
    function client.tick()
    	local body = GetPlayerGrabBody()
    	if body ~= 0 then
    		DebugPrint("Player is grabbing a body")
    	end
    end
    
    

* * *

### ReleasePlayerGrab SERVER ONLY
    
    
    ReleasePlayerGrab([playerId])

Arguments  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Release what the player is currently holding 
    
    
    function server.tick()
    	if InputPressed("jump", playerId) then
    		ReleasePlayerGrab(playerId)
    	end
    end
    
    

* * *

### GetPlayerGrabPoint 
    
    
    pos = GetPlayerGrabPoint([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
pos (TVec) - The world space grab point.  

    
    
    local body = GetPlayerGrabBody()
    if body ~= 0 then
    	local pos = GetPlayerGrabPoint()
    end
    
    

* * *

### GetPlayerPickShape 
    
    
    handle = GetPlayerPickShape([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
handle (number) - Handle to picked shape or zero if nothing is picked  

    
    
    function client.tick()
    	local shape = GetPlayerPickShape()
    	if shape ~= 0 then
    		DebugPrint("Picked shape " .. shape)
    	end
    end
    
    

* * *

### GetPlayerPickBody 
    
    
    handle = GetPlayerPickBody([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
handle (number) - Handle to picked body or zero if nothing is picked  

    
    
    function client.tick()
    	local body = GetPlayerPickBody()
    	if body ~= 0 then
    		DebugWatch("Pick body ", body)
    	end
    end
    
    

* * *

### GetPlayerInteractShape 
    
    
    handle = GetPlayerInteractShape([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
handle (number) - Handle to interactable shape or zero  


Interactable shapes has to be tagged with "interact". The engine determines which interactable shape is currently interactable. 
    
    
    function client.tick()
    	local shape = GetPlayerInteractShape()
    	if shape ~= 0 then
    		DebugPrint("Interact shape " .. shape)
    	end
    end
    
    

* * *

### GetPlayerInteractBody 
    
    
    handle = GetPlayerInteractBody([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
handle (number) - Handle to interactable body or zero  


Interactable shapes has to be tagged with "interact". The engine determines which interactable body is currently interactable. 
    
    
    function client.tick()
    	local body = GetPlayerInteractBody()
    	if body ~= 0 then
    		DebugPrint("Interact body " .. body)
    	end
    end
    
    

* * *

### SetPlayerScreen SERVER ONLY
    
    
    SetPlayerScreen(handle, [playerId])

Arguments  
handle (number) - Handle to screen or zero for no screen  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Set the screen the player should interact with. For the screen to feature a mouse pointer and receieve input, the screen also needs to have interactive property. 
    
    
    function server.tick()
    	if InputPressed("interact", playerId) then
    		if GetPlayerScreen(playerId) ~= 0 then
    			SetPlayerScreen(0, playerId)
    		else
    			SetPlayerScreen(screen, playerId)
    		end
    
    	end
    end
    
    

* * *

### GetPlayerScreen 
    
    
    handle = GetPlayerScreen([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
handle (number) - Handle to interacted screen or zero if none  

    
    
    function server.tick()
    	if InputPressed("interact", playerId) then
    		if GetPlayerScreen(playerId) ~= 0 then
    			SetPlayerScreen(0, playerId)
    		else
    			SetPlayerScreen(screen, playerId)
    		end
    
    	end
    end
    
    

* * *

### SetPlayerHealth SERVER ONLY
    
    
    SetPlayerHealth(health, [playerId])

Arguments  
health (number) - Set player health (between zero and one)  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none
    
    
    function server.tick()
    	if InputPressed("interact", playerId) then
    		if GetPlayerHealth() < 0.75 then
    			SetPlayerHealth(1.0, playerId)
    		else
    			SetPlayerHealth(0.5, playerId)
    		end
    	end
    end
    
    

* * *

### GetPlayerHealth 
    
    
    health = GetPlayerHealth([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
health (number) - Current player health  

    
    
    function server.tick()
    	if InputPressed("interact", playerId) then
    		if GetPlayerHealth() < 0.75 then
    			SetPlayerHealth(1.0, playerId)
    		else
    			SetPlayerHealth(0.5, playerId)
    		end
    	end
    end
    
    

* * *

### GetPlayerCanUseTool 
    
    
    canusetool = GetPlayerCanUseTool([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
canusetool (bool) - If the player currenty can use tool.  


Will be false if player is in vehicle, interacting with a screen, has pause menu open, is dead or uses interactive UI. 
    
    
    function server.tick()
    	for p in Players() do
    		if GetPlayerCanUseTool(p) and InputPressed("usetool", p) then
    			-- fire laser
    		end
    	end
    end
    
    

* * *

### SetPlayerRegenerationState SERVER ONLY
    
    
    SetPlayerRegenerationState(state, [player])

Arguments  
state (boolean) - State of player regeneration  
player (number, optional) - Player ID change regeneration for  


Return value  
none

Enable or disable regeneration for player 
    
    
    function playerJoined(playerId)
    	-- initially disable regeneration for player
    	SetPlayerRegenerationState(false, playerId)
    end
    
    

* * *

### SetPlayerTool SERVER ONLY
    
    
    SetPlayerTool(toolId, [playerId])

Arguments  
toolId (string) - Set Tool ID  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none
    
    
    function playerJoined(playerId)
    	-- Server sets player tool to "gun"
    	SetPlayerTool("gun", playerId)
    end
    
    

* * *

### GetPlayerTool 
    
    
    toolId = GetPlayerTool([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
toolId (string) - Get Tool ID  

    
    
    local tool = GetPlayerTool()
    
    

* * *

### RespawnPlayer SERVER ONLY
    
    
    RespawnPlayer([playerId])

Arguments  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Respawn player at spawn position without modifying the scene 
    
    
    function server.tick()
    	for p in Players() do
    		if InputPressed("interact", p) then
    			RespawnPlayer(p)
    		end
    	end
    end
    
    

* * *

### RespawnPlayerAtTransform SERVER ONLY
    
    
    RespawnPlayerAtTransform(transform, [playerId])

Arguments  
transform (transform) - Transform  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

Respawn player at spawn position without modifying the scene 
    
    
    function server.tick()
    	for p in Players() do
    		if InputPressed("interact", p) then
    			RespawnPlayerAtTransform(Transform(Vec(1,2,3)), p)
    		end
    	end
    end
    
    

* * *

### GetPlayerWalkingSpeed 
    
    
    speed = GetPlayerWalkingSpeed([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
speed (number) - Current player base walking speed  


This function gets base speed, but real player speed depends on many factors such as health, crouch, water, grabbing objects. 
    
    
    function client.tick()
    	DebugPrint(GetPlayerWalkingSpeed())
    end
    
    

* * *

### SetPlayerWalkingSpeed SERVER ONLY
    
    
    SetPlayerWalkingSpeed(speed, [playerId])

Arguments  
speed (number) - Set player walking speed  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

This function sets base speed, but real player speed depends on many factors such as health, crouch, water, grabbing objects. 
    
    
    function server.tick()
    
    	for p in Players() do
    		-- Set player walking speed based on whether shift is pressed
    		if InputDown("shift", p) then
    			SetPlayerWalkingSpeed(15.0, p)
    		else
    			SetPlayerWalkingSpeed(7.0, p)
    		end
    	end
    end
    
    

* * *

### GetPlayerCrouchSpeedScale 
    
    
    speed = GetPlayerCrouchSpeedScale([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
speed (number) - Current player walking speed while crouched  

    
    
    function client.tick()
    	DebugPrint(GetPlayerCrouchSpeedScale())
    end
    
    

* * *

### SetPlayerCrouchSpeedScale SERVER ONLY
    
    
    SetPlayerCrouchSpeedScale(speed, [playerId])

Arguments  
speed (number) - Set player walking speed while crouched  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

This function sets base speed the player is changed to while crouched 
    
    
    function server.tick()
    	for p in Players() do
    		if InputDown("shift") then
    			SetPlayerCrouchSpeedScale(5.0, p)
    		else
    			SetPlayerCrouchSpeedScale(3.0, p)
    		end
    	end
    end
    
    

* * *

### GetPlayerHurtSpeedScale 
    
    
    speed = GetPlayerHurtSpeedScale([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
speed (number) - Current player walking speed when hurt  

    
    
    function client.tick()
    	DebugPrint(GetPlayerHurtSpeedScale())
    end
    
    

* * *

### SetPlayerHurtSpeedScale SERVER ONLY
    
    
    SetPlayerHurtSpeedScale(speed, [playerId])

Arguments  
speed (number) - Set player walking speed when hurt  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none

This function sets base speed the player is interpolated towards based on the health 
    
    
    function server.tick()
    	-- Reduce hurt penalty (default is 2/7 or roughly 0.29)
    	for p in Players() do
    		SetPlayerHurtSpeedScale(0.6, p)
    	end
    end
    
    

* * *

### GetPlayerParam 
    
    
    value = GetPlayerParam(parameter, [player])

Arguments  
parameter (string) - Parameter name  
player (number, optional) - Player ID. On player, zero means local player.  


Return value  
value (any) - Parameter value  


 Param name |  Type |  Description  
---|---|---  
health |  float |  Current value of the player's health.  
healthRegeneration   |  boolean   |  Is the player's health regeneration enabled.  
walkingSpeed |  float |  The player's walking speed.  
jumpSpeed |  float |  The player's jump speed.  
godMode |  boolean   |  If the value is True, the player does not lose health  
friction |  float |  Player body friction  
frictionMode |  string |  Player friction combine mode  
flyMode |  boolean   |  If the value is True, the player will fly  
flashlightAllowed |  boolean   |  Changes ability to use flashlight  
disableInteract |  boolean   |  Disable interactions for player  
CollisionMask |  int |  Player collision mask bits (0-255) with respect to all shapes layer bits  
      
    
    function client.tick()
    	-- The parameter names are case-insensitive, so any of the specified writing styles will be correct:
    	-- "GodMode", "godmode", "godMode"
    	local paramName = "GodMode"
    	local param = GetPlayerParam(paramName)
    	DebugWatch(paramName, param)
    end
    
    

* * *

### SetPlayerParam SERVER ONLY
    
    
    SetPlayerParam(parameter, value, [player])

Arguments  
parameter (string) - Parameter name  
value (any) - Parameter value  
player (number, optional) - Player ID. On player, zero means local player.  


Return value  
none

 Param name |  Type |  Description  
---|---|---  
health |  float |  Current value of the player's health.  
healthRegeneration   |  boolean   |  Is the player's health regeneration enabled.  
walkingSpeed |  float |  The player's walking speed. **This value is applied for 1 frame!**  
jumpSpeed |  float |  The player's jump speed. The height of the jump depends non-linearly on the jump speed. **This value is applied for 1 frame!**  
godMode |  boolean   |  If the value is True, the player does not lose health  
friction |  float |  Player body friction. Default is 0.8  
frictionMode |  string |  Player friction combine mode. Can be (average|minimum|multiply|maximum)  
flyMode |  boolean   |  If the value is True, the player will fly  
flashlightAllowed |  boolean   |  Changes ability to use flashlight  
disableInteract |  boolean   |  Disable interactions for player  
CollisionMask |  int |  Player collision mask bits (0-255) with respect to all shapes layer bits  
      
    
    function server.tick()
    	-- The parameter names are case-insensitive, so any of the specified writing styles will be correct:
    	-- "JumpSpeed", "jumpspeed", "jumpSpeed"
    	local paramName = "JumpSpeed"
    
    	for p in Players() do
    		-- Set player jump speed based on whether shift is pressed
    		if InputDown("shift", p) then
    			SetPlayerParam(paramName, 10, p)
    		else
    			SetPlayerParam(paramName, 5, p)
    		end
    	end
    end
    
    

* * *

### SetPlayerHidden 
    
    
    SetPlayerHidden([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

Use this function to hide the player character. 
    
    
    
    function client.tick()
    	...
    	SetCameraTransform(t)
    	SetPlayerHidden()
    end
    
    

* * *

### RegisterTool SERVER ONLY
    
    
    RegisterTool(id, name, file, [group])

Arguments  
id (string) - Tool unique identifier  
name (string) - Tool name to show in hud  
file (string) - Path to vox file or prefab xml  
group (number, optional) - Tool group for this tool (1-6) Default is 6.  


Return value  
none

Register a custom tool that will show up in the player inventory and can be selected with scroll wheel. Do this only once per tool. Tools are disabled by default after RegisterTool and must be enabled per player using SetToolEnabled before they can be selected or used. 
    
    
    
    #include "script/include/player.lua"
    
    function server.init()
    	RegisterTool("lasergun", "Laser Gun", "MOD/vox/lasergun.vox", 6)
    end
    
    function server.tick()
    
    	for p in PlayersAdded() do
    		SetToolEnabled("lasergun", true, p)
    		SetToolAmmo("lasergun", 60, p)
    	end
    
    	for p in Players() do
    		if GetPlayerTool(p) == "lasergun" then
    			--Tool is selected. Tool logic goes here.
    			if InputPressed("usetool", p) then
    				-- Fire the tool
    			end
    		end
    	end
    end
    
    function client.tick()
    	for p in Players() do
    		if GetPlayerTool(p) == "lasergun" then
    			if InputPressed("usetool", p) then
    				-- Spawn client side particles, play sound, etc.
    			end
    		end
    	end
    end
    
    
    

* * *

### SetToolAmmoPickupAmount SERVER ONLY
    
    
    SetToolAmmoPickupAmount(toolId, ammo)

Arguments  
toolId (string) - Tool ID  
ammo (number) - The default ammo pickup amount  


Return value  
none

Sets the default amount of ammo granted when picking up an ammo crate associated with a specific tool. This is useful if your mod provides custom crates or ammo pickups for tools. 
    
    
    function server.init()
    	RegisterTool("lasergun", "Laser Gun", "MOD/vox/lasergun.vox", 6)
    	SetToolAmmoPickupAmount("lasergun", 30)
    end
    
    

* * *

### GetToolAmmoPickupAmount 
    
    
    ammo = GetToolAmmoPickupAmount(toolId)

Arguments  
toolId (string) - Tool ID  


Return value  
ammo (number) - The default ammo pickup amount  

    
    
    local ammo = GetToolAmmoPickupAmount("gun")
    
    

* * *

### GetToolBody 
    
    
    handle = GetToolBody([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
handle (number) - Handle to currently visible tool body or zero if none  


Return body handle of the visible tool. You can use this to retrieve tool shapes and animate them, change emissiveness, etc. Do not attempt to set the tool body transform, since it is controlled by the engine. Use SetToolTranform for that. 
    
    
    function client.tick()
    	local toolBody = GetToolBody()
    	if toolBody~=0 then
    		DebugPrint("Tool body: " .. toolBody)
    	end
    end
    
    

* * *

### GetToolHandPoseLocalTransform 
    
    
    right, left = GetToolHandPoseLocalTransform([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
right (TTransform) - Transform of right hand relative to the tool body origin, or nil if the right hand is not used  
left (TTransform) - Transform of left hand, or nil if left hand is not used  

    
    
    local right, left = GetToolHandPoseLocalTransform()
    
    

* * *

### GetToolHandPoseWorldTransform 
    
    
    right, left = GetToolHandPoseWorldTransform([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
right (TTransform) - Transform of right hand in world space, or nil if the right hand is not used  
left (TTransform) - Transform of left hand, or nil if left hand is not used  

    
    
    local right, left = GetToolHandPoseWorldTransform()
    
    

* * *

### SetToolHandPoseLocalTransform CLIENT ONLY
    
    
    SetToolHandPoseLocalTransform(right, left, [playerId])

Arguments  
right (TTransform) - Transform of right hand relative to the tool body origin, or nil if right hand is not used  
left (TTransform) - Transform of left hand, or nil if left hand is not used  
playerId (number, optional) - Player ID. On client, zero means client player.  


Return value  
none

Use this function to position the character's hands on the currently equipped tool. This function must be called every frame from the tick function. In third-person view, failing to call this function can lead to different outcomes depending on how the tool is animated: 

  * If the tool's transform is not explicitly set or is set using SetToolTransform, not calling this function will trigger a fallback solution where the right hand is automatically positioned.
  * If the tool is animated using the SetToolTransformOverride function, not calling this function will result in the character's animation taking control of the hand movement


    
    
    if GetBool("game.thirdperson") then
    	if aiming then
    		SetToolHandPoseLocalTransform(Transform(Vec(0.2,0.0,0.0), QuatAxisAngle(Vec(0,1,0), 90.0)), Transform(Vec(-0.1, 0.0, -0.4)))
    	else
    		SetToolHandPoseLocalTransform(Transform(Vec(0.2,0.0,0.0), QuatAxisAngle(Vec(0,1,0), 90.0)), nil)
    	end
    end
    
    

* * *

### GetToolLocationLocalTransform 
    
    
    location = GetToolLocationLocalTransform(name, [playerId])

Arguments  
name (string) - Name of location  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
location (TTransform) - Transform of a tool location in tool space or nil if location is not found.  


Return transform of a tool location in tool space. Locations can be defined using the tool prefab editor. 
    
    
    local right  = GetToolLocationLocalTransform("righthand")
    SetToolHandPoseLocalTransform(right, nil)
    
    

* * *

### GetToolLocationWorldTransform 
    
    
    location = GetToolLocationWorldTransform(name, [playerId])

Arguments  
name (string) - Name of location  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
location (TTransform) - Transform of a tool location in world space or nil if the location is not found or if there is no visible tool body.  


Return transform of a tool location in world space. Locations can be defined using the tool prefab editor. A tool location is defined in tool space and to get the world space transform a tool body is required. If a tool body does not exist this function will return nil. 
    
    
    local muzzle = GetToolLocationWorldTransform("muzzle")
    Shoot(muzzle, direction)
    
    

* * *

### SetToolTransform CLIENT ONLY
    
    
    SetToolTransform(transform, [sway], [playerId])

Arguments  
transform (TTransform) - Tool body transform  
sway (number, optional) - Tool sway amount. Default is 1.0  
playerId (number, optional) - Player ID. On client, zero means client player.  


Return value  
none

Apply an additional transform on the visible tool body. This can be used to create tool animations. You need to set this every frame from the tick function. The optional sway parameter control the amount of tool swaying when walking. Set to zero to disable completely. 
    
    
    function client.tick()
    	--Offset the tool half a meter to the right for the local player
    	local offset = Transform(Vec(0.5, 0, 0))
    	SetToolTransform(offset)
    end
    
    

* * *

### SetToolAllowedZoom CLIENT ONLY
    
    
    SetToolAllowedZoom(zoom, [zoom sensitivity])

Arguments  
zoom (number) - Zoom factor  
zoom sensitivity (number, optional) - Input sensitivity when zoomed in. Default is 1.0.  


Return value  
none

Set the allowed zoom for a registered tool. The zoom sensitivity will be factored with the user options for sensitivity. 
    
    
    function client.tick()
    	-- allow our scoped tool to zoom by factor 4.
    	SetToolAllowedZoom(4.0, 0.5)
    end
    
    

* * *

### SetToolTransformOverride CLIENT ONLY
    
    
    SetToolTransformOverride(transform, [playerId])

Arguments  
transform (TTransform) - Tool body transform  
playerId (number, optional) - Player ID. On client, zero means client player.  


Return value  
none

This function serves as an alternative to SetToolTransform, providing full control over tool animation by disabling all internal tool animations. When using this function, you must manually include pitch, sway, and crouch movements in the transform. To maintain this control, call the function every frame from the tick function. 
    
    
    function client.tick()
    
    	if GetBool("game.thirdperson") then
    		local toolTransform = Transform(Vec(0.3, -0.3, -0.2), Quat(0.0, 0.0, 15.0))
    
    		-- Rotate around point
    		local pivotPoint = Vec(-0.01, -0.2, 0.04)
    		toolTransform.pos = VecSub(toolTransform.pos, pivotPoint)
    		local rotation = Transform(Vec(), QuatAxisAngle(Vec(0,0,1), GetPlayerPitch()))
    		toolTransform = TransformToParentTransform(rotation, toolTransform)
    		toolTransform.pos = VecAdd(toolTransform.pos, pivotPoint)
    
    		SetToolTransformOverride(toolTransform)
    	else
    		local toolTransform = Transform(Vec(0.3, -0.3, -0.2), Quat(0.0, 0.0, 15.0))
    		SetToolTransform(toolTransform)
    	end
    end
    
    

* * *

### SetToolOffset CLIENT ONLY
    
    
    SetToolOffset(offset, [playerId])

Arguments  
offset (TVec) - Tool body offset  
playerId (number, optional) - Player ID. On client, zero means client player.  


Return value  
none

Apply an additional offset on the visible tool body. This can be used to tweak tool placement for different characters. You need to set this every frame from the tick function. 
    
    
    function client.tick()
    	--Offset the tool depending on character height
    	local defaultEyeY = 1.7
    	local offsetY = characterHeight - defaultEyeY
    	local offset = Vec(0, offsetY, 0)
    	SetToolOffset(offset)
    end
    
    

* * *

### SetToolAmmo SERVER ONLY
    
    
    SetToolAmmo(toolId, ammo, [playerId])

Arguments  
toolId (string) - Tool ID  
ammo (number) - Total ammo  
playerId (number, optional) - Player ID. On server, zero means server (host) player.  


Return value  
none
    
    
    SetToolAmmo("gun", 10, 1)
    
    

* * *

### GetToolAmmo 
    
    
    ammo = GetToolAmmo(toolId, [playerId])

Arguments  
toolId (string) - Tool ID  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
ammo (number) - Total ammo for tool  

    
    
    local ammo = GetToolAmmo("gun", 1)
    
    

* * *

### SetToolEnabled SERVER ONLY
    
    
    SetToolEnabled(toolId, enabled, [playerId])

Arguments  
toolId (string) - Tool ID  
enabled (bool) - Tool enabled  
playerId (number, optional) - Player ID  


Return value  
none
    
    
    SetToolEnabled("gun", false, playerId)
    
    

* * *

### IsToolEnabled 
    
    
    enabled = IsToolEnabled(toolId, [playerId])

Arguments  
toolId (string) - Tool ID  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
enabled (bool) - Tool enabled for player  

    
    
    if IsToolEnabled("gun", 1) then
    	...
    end
    
    

* * *

### SetPlayerOrientation SERVER ONLY
    
    
    SetPlayerOrientation(orientation, [playerId])

Arguments  
orientation (Quat) - Base orientation  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

Sets the base orientation when gravity is disabled with SetGravity. This will determine what direction is "up", "right" and "forward" as gravity is completely turned off. 
    
    
    function server.tick()
    	SetGravity(Vec(0, 0, 0))
    
    	-- Turn players upside-down.
    	for p in Players() do
    		SetPlayerOrientation(QuatAxisAngle(Vec(1,0,0), 180), p)
    	end
    end
    
    

* * *

### GetPlayerOrientation 
    
    
    GetPlayerOrientation([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

Gets the base orientation of the player. This can be used to retrieve the base orientation of the player when using a custom gravity vector. 
    
    
    function server.tick(dt)
    	SetGravity(Vec(0, 0, 0))
    
    	for p in Players() do
    		-- Spin the player if using zero gravity
    		local base = QuatRotateQuat(GetPlayerOrientation(p), QuatAxisAngle(Vec(1,0,0), dt))
    		SetPlayerOrientation(base, p)
    	end
    end
    
    

* * *

### GetPlayerUp 
    
    
    up = GetPlayerUp([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
up (TVec) - Up vector of the player  


This function returns the up vector of the player, which is determined by the player's base orientation. 
    
    
    function client.tick()
    	local up = GetPlayerUp()
    	DebugPrint("Player up vector: " .. up)
    end
    
    

* * *

### SetPlayerRig 
    
    
    SetPlayerRig(rig, [playerId])

Arguments  
rig (number) - Rig handle  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none
    
    
        local rig = FindRig("myrig")
        SetPlayerRig(rig)
    
    

* * *

### GetPlayerRig 
    
    
    rig = GetPlayerRig([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
rig (number) - Rig handle  

    
    
    local rig = GetPlayerRig(rigid)
    
    

* * *

### GetPlayerRigWorldTransform 
    
    
    transform = GetPlayerRigWorldTransform([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
transform (TTransform) - World transform, nil if player doesnt have a rig  

    
    
    local t = GetPlayerRigWorldTransform()
    
    

* * *

### ClearPlayerRig 
    
    
    ClearPlayerRig(rig-id, [playerId])

Arguments  
rig-id (number) - Unique rig-id, -1 means all rigs  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

**This function will be deprecated in the next update!**  

    
    
        ClearPlayerRig(someId)
    
    

* * *

### SetPlayerRigLocationLocalTransform 
    
    
    SetPlayerRigLocationLocalTransform(rig-id, name, location, [playerId])

Arguments  
rig-id (number) - Unique id  
name (string) - Name of location  
location (table) - Rig Local transform of the location  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

**This function will be deprecated in the next update!**  

    
    
        local someBody = FindBody("bodyname")
        SetPlayerRigLocationLocalTransform(someBody, "ik_foot_l", TransformToLocalTransform(GetBodyTransform(someBody), GetLocationTransform(FindLocation("ik_foot_l"))))
    
    

* * *

### SetPlayerRigTransform 
    
    
    SetPlayerRigTransform(rig-id, location, [playerId])

Arguments  
rig-id (number) - Unique id  
location (table) - New world transform  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

This will both update the rig identified by the 'id' and make it active **This function will be deprecated in the next update!**  

    
    
        local someBody = FindBody("bodyname")
        SetPlayerRigTransform(someBody, GetBodyTransform(someBody))
    
    

* * *

### GetPlayerRigLocationWorldTransform 
    
    
    location = GetPlayerRigLocationWorldTransform(name, [playerId])

Arguments  
name (string) - Name of location  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
location (table) - Transform of a location in world space  


**This function will be deprecated in the next update!**  

    
    
    local t = GetPlayerRigLocationWorldTransform("ik_hand_l")
    
    

* * *

### SetPlayerRigTags CLIENT ONLY
    
    
    SetPlayerRigTags(rig-id, tag, [playerId])

Arguments  
rig-id (number) - Unique id  
tag (string) - Tag  
playerId (number, optional) - Player ID. On client, zero means client player.  


Return value  
none

**This function will be deprecated in the next update!**  


* * *

### GetPlayerRigHasTag 
    
    
    exists = GetPlayerRigHasTag(tag, [playerId])

Arguments  
tag (string) - Tag name  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
exists (boolean) - Returns true if entity has tag  


**This function will be deprecated in the next update!**  


* * *

### GetPlayerRigTagValue 
    
    
    value = GetPlayerRigTagValue(tag, [playerId])

Arguments  
tag (string) - Tag name  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
value (string) - Returns the tag value, if any. Empty string otherwise.  


**This function will be deprecated in the next update!**  


* * *

### GetPlayerColor 
    
    
    inuse, r, g, b = GetPlayerColor([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
inuse (boolean) - If color is used or not  
r (number) - Red channel value  
g (number) - Green channel value  
b (number) - Blue channel value  

    
    
    function client.tick()
    	local inuse, r, g, b = GetPlayerColor()
    	if inuse then
    		DebugPrint("Player color: " .. r .. ", " .. g .. ", " .. b)
    	else
    		DebugPrint("Player color is not set")
    	end
    end
    
    

* * *

### SetPlayerColor 
    
    
    SetPlayerColor(r, g, b, [playerId])

Arguments  
r (number) - Red value  
g (number) - Green value  
b (number) - Blue value  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none
    
    
    end
    function client.tick()
    	local r, g, b = 1.0, 0.5, 0.2
    	SetPlayerColor(r, g, b)
    	DebugPrint("Set player color to: " .. r .. ", " .. g .. ", " .. b)
    end
    
    

* * *

### ApplyPlayerDamage SERVER ONLY
    
    
    ApplyPlayerDamage(targetPlayerId, damage, [cause], [instigatingPlayerId])

Arguments  
targetPlayerId (number) - Target player ID  
damage (number) - Damage to apply to target player  
cause (string, optional) - The cause of damage  
instigatingPlayerId (number, optional) - Instigating player ID.  


Return value  
none

Apply damage to a player. Instigating player ID could be used to correctly attribute the "score" to a player. 
    
    
    function server.tick(dt)
    	
    	for player in Players() do
    		if isOnFire(player) then
    			-- Apply 20% of dt as damage to the player
    			ApplyPlayerDamage(player, 0.2 * dt, "fire")
    		end
    	end
    	
    	-- or
    
    	for player in Players() do
    		if InputIsPressed("usetool", player) then
    			for target in Players() do
    				if target ~= player and isInRange(player, target) then
    					-- Apply 50% damage to the target player
    					ApplyPlayerDamage(target, 0.5, "tool", player)
    				end
    			end
    		end
    	end
    end
    
    

* * *

### DisablePlayerInput SERVER ONLY
    
    
    DisablePlayerInput(player)

Arguments  
player (playerIndex) - Player to disable input for  


Return value  
none

Disable input for a player. Should be called from tick. 
    
    
    -- Disable player 2 input as she/he is interacting with something.
    DisablePlayerInput(2)
    
    

* * *

### DisablePlayer SERVER ONLY
    
    
    DisablePlayer(playerId)

Arguments  
playerId (number) - Player to disable  


Return value  
none

Disables the player from any interaction, physics and rendering. 
    
    
    function updateFinalScoreboard()
    	for i=1,#hiddenPlayers do
    		DisablePlayer(hiddenPlayers[i])
    	end
    end
    
    

* * *

### IsPlayerDisabled 
    
    
    IsPlayerDisabled(playerId)

Arguments  
playerId (number) - Check if player is disabled  


Return value  
none

Check if player is actively disabled 
    
    
    --check if disabled
    playerDisabled = IsPlayerDisabled(playerId)
    
    

* * *

### DisablePlayerDamage SERVER ONLY
    
    
    DisablePlayerDamage(playerId)

Arguments  
playerId (number) - Player for which damage should be disabled  


Return value  
none

Disables the player from any incoming damage, such as explosions, gun shots, or drowning. 
    
    
    function server.tick()
    	for i=1,#invulnerablePlayers do
    		DisablePlayerDamage(invulnerablePlayers[i])
    	end
    end
    
    

* * *

### LoadSound 
    
    
    handle = LoadSound(path, [nominalDistance])

Arguments  
path (string) - Path to ogg sound file  
nominalDistance (number, optional) - The distance in meters this sound is recorded at. Affects attenuation, default is 10.0  


Return value  
handle (number) - Sound handle  

    
    
    function client.init()
    	local snd = LoadSound("warning-beep.ogg")
    end
    
    

* * *

### UnloadSound 
    
    
    UnloadSound(handle)

Arguments  
handle (number) - Sound handle  


Return value  
none
    
    
    function client.init()
    	local snd = LoadSound("warning-beep.ogg")
    	UnloadSound(snd)
    end
    
    

* * *

### LoadLoop 
    
    
    handle = LoadLoop(path, [nominalDistance])

Arguments  
path (string) - Path to ogg sound file  
nominalDistance (number, optional) - The distance in meters this sound is recorded at. Affects attenuation, default is 10.0  


Return value  
handle (number) - Loop handle  

    
    
    local loop
    function client.init()
    	loop = LoadLoop("radio/jazz.ogg")
    end
    
    function client.tick()
    	local pos = Vec(0, 0, 0)
    	PlayLoop(loop, pos, 1.0)
    end
    
    

* * *

### UnloadLoop 
    
    
    UnloadLoop(handle)

Arguments  
handle (number) - Loop handle  


Return value  
none
    
    
    local loop = -1
    function client.init()
    	loop = LoadLoop("radio/jazz.ogg")
    end
    
    function client.tick()
    	if loop ~= -1 then
    		local pos = Vec(0, 0, 0)
    		PlayLoop(loop, pos, 1.0)
    	end
    
    	if InputPressed("space") then
    		UnloadLoop(loop)
    		loop = -1
    	end
    end
    
    

* * *

### SetSoundLoopUser CLIENT ONLY
    
    
    flag = SetSoundLoopUser(handle, nominalDistance)

Arguments  
handle (number) - Loop handle  
nominalDistance (number) - User index  


Return value  
flag (boolean) - TRUE if sound applied to gamepad speaker, FALSE otherwise.  

    
    
    function client.init()
    	local loop = LoadLoop("radio/jazz.ogg")
    	SetSoundLoopUser(loop, 0)
    end
    --This function will move (if possible) sound to gamepad of appropriate user
    
    

* * *

### PlaySound 
    
    
    handle = PlaySound(handle, [pos], [volume], [registerVolume], [pitch])

Arguments  
handle (number) - Sound handle  
pos (TVec, optional) - World position as vector. Default is player position.  
volume (number, optional) - Playback volume. Default is 1.0  
registerVolume (boolean, optional) - Register position and volume of this sound for GetLastSound. Default is true  
pitch (number, optional) - Playback pitch. Default 1.0  


Return value  
handle (number) - Sound play handle  

    
    
    local snd
    function client.init()
    	snd = LoadSound("warning-beep.ogg")
    end
    
    function client.tick()
    	if InputPressed("interact") then
    		local pos = Vec(0, 0, 0)
    		PlaySound(snd, pos, 0.5)
    	end
    end
    
    -- If you have a list of sound files and you add a sequence number, starting from zero, at the end of each filename like below,
    -- then each time you call PlaySound it will pick a random sound from that list and play that sound.
    
    -- "example-sound0.ogg"
    -- "example-sound1.ogg"
    -- "example-sound2.ogg"
    -- "example-sound3.ogg"
    -- ...
    --[[
    	local snd
    	function client.init()
    		snd = LoadSound("example-sound0.ogg")
    	end
    
    	-- Plays a random sound from the loaded sound series
    	function client.tick()
    		if trigSound then
    			local pos = Vec(100, 0, 0)
    			PlaySound(snd, pos, 0.5)
    		end
    	end
    ]]
    
    

* * *

### PlaySoundForUser CLIENT ONLY
    
    
    handle = PlaySoundForUser(handle, user, [pos], [volume], [registerVolume], [pitch])

Arguments  
handle (number) - Sound handle  
user (number) - Index of user to play.  
pos (TVec, optional) - World position as vector. Default is player position.  
volume (number, optional) - Playback volume. Default is 1.0  
registerVolume (boolean, optional) - Register position and volume of this sound for GetLastSound. Default is true  
pitch (number, optional) - Playback pitch. Default 1.0  


Return value  
handle (number) - Sound play handle  

    
    
    local snd
    function client.init()
    	snd = LoadSound("warning-beep.ogg")
    end
    
    function client.tick()
    	if InputPressed("interact") then
    		PlaySoundForUser(snd, 0)
    	end
    end
    
    -- If you have a list of sound files and you add a sequence number, starting from zero, at the end of each filename like below,
    -- then each time you call PlaySoundForUser it will pick a random sound from that list and play that sound.
    
    -- "example-sound0.ogg"
    -- "example-sound1.ogg"
    -- "example-sound2.ogg"
    -- "example-sound3.ogg"
    -- ...
    
    --[[
    	local snd
    	function client.init()
    		snd = LoadSound("example-sound0.ogg")
    	end
    
    	-- Plays a random sound from the loaded sound series
    	function client.tick()
    		if trigSound then
    			local pos = Vec(100, 0, 0)
    			PlaySoundForUser(snd, 0, pos, 0.5)
    		end
    	end
    ]]
    
    

* * *

### StopSound 
    
    
    StopSound(handle)

Arguments  
handle (number) - Sound play handle  


Return value  
none
    
    
    local snd
    function client.init()
    	snd = LoadSound("radio/jazz.ogg")
    end
    
    local sndPlay
    function client.tick()
    	if InputPressed("interact") then
    		if not IsSoundPlaying(sndPlay) then
    			local pos = Vec(0, 0, 0)
    			sndPlay = PlaySound(snd, pos, 0.5)
    		else
    			StopSound(sndPlay)
    		end
    	end
    end
    
    

* * *

### IsSoundPlaying 
    
    
    playing = IsSoundPlaying(handle)

Arguments  
handle (number) - Sound play handle  


Return value  
playing (boolean) - True if sound is playing, false otherwise.  

    
    
    local snd
    function client.init()
    	snd = LoadSound("radio/jazz.ogg")
    end
    
    local sndPlay
    function client.tick()
    	if InputPressed("interact") then
    		if not IsSoundPlaying(sndPlay) then
    			local pos = Vec(0, 0, 0)
    			sndPlay = PlaySound(snd, pos, 0.5)
    		else
    			StopSound(sndPlay)
    		end
    	end
    end
    
    

* * *

### GetSoundProgress 
    
    
    progress = GetSoundProgress(handle)

Arguments  
handle (number) - Sound play handle  


Return value  
progress (number) - Current sound progress in seconds.  

    
    
    local snd
    function client.init()
    	snd = LoadSound("radio/jazz.ogg")
    end
    
    local sndPlay
    function client.tick()
    	if InputPressed("interact") then
    		if not IsSoundPlaying(sndPlay) then
    			local pos = Vec(0, 0, 0)
    			sndPlay = PlaySound(snd, pos, 0.5)
    		else
    			SetSoundProgress(sndPlay, GetSoundProgress(sndPlay) - 1.0)
    		end
    	end
    end
    
    

* * *

### SetSoundProgress 
    
    
    SetSoundProgress(handle, progress)

Arguments  
handle (number) - Sound play handle  
progress (number) - Progress in seconds  


Return value  
none
    
    
    local snd
    function client.init()
    	snd = LoadSound("radio/jazz.ogg")
    end
    
    local sndPlay
    function client.tick()
    	if InputPressed("interact") then
    		if not IsSoundPlaying(sndPlay) then
    			local pos = Vec(0, 0, 0)
    			sndPlay = PlaySound(snd, pos, 0.5)
    		else
    			SetSoundProgress(sndPlay, GetSoundProgress(sndPlay) - 1.0)
    		end
    	end
    end
    
    

* * *

### PlayLoop 
    
    
    PlayLoop(handle, [pos], [volume], [registerVolume], [pitch])

Arguments  
handle (number) - Loop handle  
pos (TVec, optional) - World position as vector. Default is player position.  
volume (number, optional) - Playback volume. Default is 1.0  
registerVolume (boolean, optional) - Register position and volume of this sound for GetLastSound. Default is true  
pitch (number, optional) - Playback pitch. Default 1.0  


Return value  
none

Call this function continuously to play loop 
    
    
    local loop
    function client.init()
    	loop = LoadLoop("radio/jazz.ogg")
    end
    
    function client.tick()
    	local pos = Vec(0, 0, 0)
    	PlayLoop(loop, pos, 1.0)
    end
    
    

* * *

### GetSoundLoopProgress 
    
    
    progress = GetSoundLoopProgress(handle)

Arguments  
handle (number) - Loop handle  


Return value  
progress (number) - Current music progress in seconds.  

    
    
    function client.init()
    	loop = LoadLoop("radio/jazz.ogg")
    end
    
    function client.tick()
    	local pos = Vec(0, 0, 0)
    	PlayLoop(loop, pos, 1.0)
    	if InputPressed("interact") then
    		SetSoundLoopProgress(loop, GetSoundLoopProgress(loop) - 1.0)
    	end
    end
    
    

* * *

### SetSoundLoopProgress 
    
    
    SetSoundLoopProgress(handle, [progress])

Arguments  
handle (number) - Loop handle  
progress (number, optional) - Progress in seconds. Default 0.0.  


Return value  
none
    
    
    function client.init()
    	loop = LoadLoop("radio/jazz.ogg")
    end
    
    function client.tick()
    	local pos = Vec(0, 0, 0)
    	PlayLoop(loop, pos, 1.0)
    	if InputPressed("interact") then
    		SetSoundLoopProgress(loop, GetSoundLoopProgress(loop) - 1.0)
    	end
    end
    
    

* * *

### PlayMusic 
    
    
    PlayMusic(path)

Arguments  
path (string) - Music path  


Return value  
none
    
    
    function client.init()
    	PlayMusic("about.ogg")
    end
    
    

* * *

### StopMusic 
    
    
    StopMusic()

Arguments  
none

Return value  
none
    
    
    function client.init()
    	PlayMusic("about.ogg")
    end
    
    function client.tick()
    	if InputDown("interact") then
    		StopMusic()
    	end
    end
    
    

* * *

### IsMusicPlaying 
    
    
    playing = IsMusicPlaying()

Arguments  
none

Return value  
playing (boolean) - True if music is playing, false otherwise.  

    
    
    function client.init()
    	PlayMusic("about.ogg")
    end
    
    function client.tick()
    	if InputPressed("interact") and IsMusicPlaying() then
    		DebugPrint("music is playing")
    	end
    end
    
    

* * *

### SetMusicPaused 
    
    
    SetMusicPaused(paused)

Arguments  
paused (boolean) - True to pause, false to resume.  


Return value  
none
    
    
    function client.init()
    	PlayMusic("about.ogg")
    end
    
    function client.tick()
    	if InputPressed("interact") then
    		SetMusicPaused(IsMusicPlaying())
    	end
    end
    
    

* * *

### GetMusicProgress 
    
    
    progress = GetMusicProgress()

Arguments  
none

Return value  
progress (number) - Current music progress in seconds.  

    
    
    function client.init()
    	PlayMusic("about.ogg")
    end
    
    function client.tick()
    	if InputPressed("interact") then
    		DebugPrint(GetMusicProgress())
    	end
    end
    
    

* * *

### SetMusicProgress 
    
    
    SetMusicProgress([progress])

Arguments  
progress (number, optional) - Progress in seconds. Default 0.0.  


Return value  
none
    
    
    function client.init()
    	PlayMusic("about.ogg")
    end
    
    function client.tick()
    	if InputPressed("interact") then
     		SetMusicProgress(GetMusicProgress() - 1.0)
    	end
    end
    
    

* * *

### SetMusicVolume 
    
    
    SetMusicVolume(volume)

Arguments  
volume (number) - Music volume.  


Return value  
none

Override current music volume for this frame. Call continuously to keep overriding. 
    
    
    function client.init()
    	PlayMusic("about.ogg")
    end
    
    function client.tick()
    	if InputDown("interact") then
     		SetMusicVolume(0.3)
    	end
    end
    
    

* * *

### SetMusicLowPass 
    
    
    SetMusicLowPass(wet)

Arguments  
wet (number) - Music low pass filter 0.0 - 1.0.  


Return value  
none

Override current music low pass filter for this frame. Call continuously to keep overriding. 
    
    
    function client.init()
    	PlayMusic("about.ogg")
    end
    
    function client.tick()
    	if InputDown("interact") then
     		SetMusicLowPass(0.6)
    	end
    end
    
    

* * *

### LoadSprite 
    
    
    handle = LoadSprite(path)

Arguments  
path (string) - Path to sprite. Must be PNG or JPG format.  


Return value  
handle (number) - Sprite handle  

    
    
    function client.init()
    	arrow = LoadSprite("gfx/arrowdown.png")
    end
    
    

* * *

### DrawSprite 
    
    
    DrawSprite(handle, transform, width, height, [r], [g], [b], [a], [depthTest], [additive], [fogAffected])

Arguments  
handle (number) - Sprite handle  
transform (TTransform) - Transform  
width (number) - Width in meters  
height (number) - Height in meters  
r (number, optional) - Red color. Default 1.0.  
g (number, optional) - Green color. Default 1.0.  
b (number, optional) - Blue color. Default 1.0.  
a (number, optional) - Alpha. Default 1.0.  
depthTest (boolean, optional) - Depth test enabled. Default false.  
additive (boolean, optional) - Additive blending enabled. Default false.  
fogAffected (boolean, optional) - Enable distance fog effect. Default false.  


Return value  
none

Draw sprite in world at next frame. Call this function from the tick callback. 
    
    
    function client.init()
    	arrow = LoadSprite("gfx/arrowdown.png")
    end
    
    function client.tick()
    	--Draw sprite using transform
    	--Size is two meters in width and height
    	--Color is white, fully opaue
    	local t = Transform(Vec(0, 10, 0), QuatEuler(0, GetTime(), 0))
    	DrawSprite(arrow, t, 2, 2, 1, 1, 1, 1)
    end
    
    

* * *

### QueryRequire 
    
    
    QueryRequire(layers)

Arguments  
layers (string) - Space separate list of layers  


Return value  
none

Set required layers for next query. Available layers are:  Layer |  Description  
---|---  
physical |  have a physical representation  
dynamic |  part of a dynamic body  
static |  part of a static body  
large |  above debris threshold  
small |  below debris threshold  
visible |  only hit visible shapes  
animator |  part of an animator hierarchy  
player      |  part of an player animator hierarchy  
tool        |  part of a tool  
      
    
    --Raycast dynamic, physical objects above debris threshold, but not specific vehicle
    function client.tick()
    	local vehicle = FindVehicle("vehicle")
    	QueryRequire("physical dynamic large")
    	QueryRejectVehicle(vehicle)
    	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
    	if hit then
    		DebugPrint(dist)
    	end
    end
    
    

* * *

### QueryInclude 
    
    
    QueryInclude(layers)

Arguments  
layers (string) - Space separate list of layers  


Return value  
none

Set included layers for next query. Queries include all layers except tool and player per default. Available layers are:  Layer |  Description  
---|---  
physical |  have a physical representation  
dynamic |  part of a dynamic body  
static |  part of a static body  
large |  above debris threshold  
small |  below debris threshold  
visible |  only hit visible shapes  
animator    |  part of an animator hierarchy  
player      |  part of an player  
tool        |  part of a tool  
      
    
    --Raycast all the default layers and include the player layer.
    function client.tick()
    	QueryInclude("player")
    	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
    	if hit then
    		DebugPrint(dist)
    	end
    end
    
    

* * *

### QueryCollisionMask 
    
    
    QueryCollisionMask(mask)

Arguments  
mask (number) - Mask bits (0-255)  


Return value  
none

Set collision mask filter for the next query. Queries have a mask of 255 by default 
    
    
    --Find the closest point on any shape (within 2 meters) to the player eye that the player can collide with.
    function client.tick()
    	QueryRequire("physical")
    	QueryCollisionMask(GetPlayerParam("CollisionMask"))
    	local hit, hitpos = QueryClosestPoint(GetPlayerEyeTransform().pos, 2)
    	if hit then
    		DebugCross(hitpos)
    	end
    end
    
    

* * *

### QueryRejectAnimator 
    
    
    QueryRejectAnimator(handle)

Arguments  
handle (number) - Animator handle  


Return value  
none

Exclude animator from the next query 

* * *

### QueryRejectVehicle 
    
    
    QueryRejectVehicle(vehicle)

Arguments  
vehicle (number) - Vehicle handle  


Return value  
none

Exclude vehicle from the next query 
    
    
    function client.tick()
    	local vehicle = FindVehicle("vehicle")
    	QueryRequire("physical dynamic large")
    	--Do not include vehicle in next raycast
    	QueryRejectVehicle(vehicle)
    	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
    	if hit then
    		DebugPrint(dist)
    	end
    end
    
    
    
    

* * *

### QueryRejectBody 
    
    
    QueryRejectBody(body)

Arguments  
body (number) - Body handle  


Return value  
none

Exclude body from the next query 
    
    
    function client.tick()
    	local body = FindBody("body")
    	QueryRequire("physical dynamic large")
    	--Do not include body in next raycast
    	QueryRejectBody(body)
    	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
    	if hit then
    		DebugPrint(dist)
    	end
    end
    
    

* * *

### QueryRejectBodies 
    
    
    QueryRejectBodies(bodies)

Arguments  
bodies (table) - Array with bodies handles  


Return value  
none

Exclude bodies from the next query 
    
    
    function client.tick()
    	local body = FindBody("body")
    	QueryRequire("physical dynamic large")
    	local bodies = {body}
    	--Do not include body in next raycast
    	QueryRejectBodies(bodies)
    	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
    	if hit then
    		DebugPrint(dist)
    	end
    end
    
    

* * *

### QueryRejectShape 
    
    
    QueryRejectShape(shape)

Arguments  
shape (number) - Shape handle  


Return value  
none

Exclude shape from the next query 
    
    
    function client.tick()
    	local shape = FindShape("shape")
    	QueryRequire("physical dynamic large")
    	--Do not include shape in next raycast
    	QueryRejectShape(shape)
    	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
    	if hit then
    		DebugPrint(dist)
    	end
    end
    
    

* * *

### QueryRejectShapes 
    
    
    QueryRejectShapes(shapes)

Arguments  
shapes (table) - Array with shapes handles  


Return value  
none

Exclude shapes from the next query 
    
    
    function client.tick()
    	local shape = FindShape("shape")
    	QueryRequire("physical dynamic large")
    	local shapes = {shape}
    	--Do not include shape in next raycast
    	QueryRejectShapes(shapes)
    	local hit, dist = QueryRaycast(Vec(0, 0, 0), Vec(1, 0, 0), 10)
    	if hit then
    		DebugPrint(dist)
    	end
    end
    
    

* * *

### QueryRejectPlayer 
    
    
    QueryRejectPlayer([playerId])

Arguments  
playerId (number, optional) - Player ID. On client, zero means client player. On server, zero means server (host) player.  


Return value  
none

Exclude player from the next query 
    
    
    --Do not include shape in next raycast
    QueryRejectPlayer(1)
    QueryRaycast(...)
    
    

* * *

### QueryRaycast 
    
    
    hit, dist, normal, shape = QueryRaycast(origin, direction, maxDist, [radius], [rejectTransparent])

Arguments  
origin (TVec) - Raycast origin as world space vector  
direction (TVec) - Unit length raycast direction as world space vector  
maxDist (number) - Raycast maximum distance. Keep this as low as possible for good performance.  
radius (number, optional) - Raycast thickness. Default zero.  
rejectTransparent (boolean, optional) - Raycast through transparent materials. Default false.  


Return value  
hit (boolean) - True if raycast hit something  
dist (number) - Hit distance from origin  
normal (TVec) - World space normal at hit point  
shape (number) - Handle to hit shape  


This will perform a raycast or spherecast (if radius is more than zero) query. If you want to set up a filter for the query you need to do so before every call to this function. 
    
    
    function client.init()
    	local vehicle = FindVehicle("vehicle")
    	QueryRejectVehicle(vehicle)
    	--Raycast from a high point straight downwards, excluding a specific vehicle
    	local hit, d = QueryRaycast(Vec(0, 100, 0), Vec(0, -1, 0), 100)
    	if hit then
    		DebugPrint(d)
    	end
    end
    
    

* * *

### QueryRaycastRope 
    
    
    hit, dist, joint = QueryRaycastRope(origin, direction, maxDist, [radius])

Arguments  
origin (TVec) - Raycast origin as world space vector  
direction (TVec) - Unit length raycast direction as world space vector  
maxDist (number) - Raycast maximum distance. Keep this as low as possible for good performance.  
radius (number, optional) - Raycast thickness. Default zero.  


Return value  
hit (boolean) - True if raycast hit something  
dist (number) - Hit distance from origin  
joint (number) - Handle to hit joint of rope type  


This will perform a raycast query that returns the handle of the joint of rope type when if collides with it. There are no filters for this type of raycast. 
    
    
    function client.tick()
    	local playerCameraTransform = GetPlayerCameraTransform()
    	local dir = TransformToParentVec(playerCameraTransform, Vec(0, 0, -1))
    
    	local hit, dist, joint = QueryRaycastRope(playerCameraTransform.pos, dir, 10)
    	if hit then
    		DebugWatch("distance", dist)
    		DebugWatch("joint", joint)
    	end
    end
    
    

* * *

### QueryRaycastWater 
    
    
    hit, dist, hitPos = QueryRaycastWater(origin, direction, maxDist)

Arguments  
origin (TVec) - Raycast origin as world space vector  
direction (TVec) - Unit length raycast direction as world space vector  
maxDist (number) - Raycast maximum distance. Keep this as low as possible for good performance.  


Return value  
hit (boolean) - True if raycast hit something  
dist (number) - Hit distance from origin  
hitPos (TVec) - Hit point as world space vector  


This will perform a raycast query looking for water. 
    
    
    function client.init()
    	--Raycast from a high point straight downwards, looking for water
    	local hit, d = QueryRaycast(Vec(0, 100, 0), Vec(0, -1, 0), 100)
    	if hit then
    		DebugPrint(d)
    	end
    end
    
    

* * *

### QueryShot 
    
    
    didHit, dist, shape, playerId, playerDamageFactor, normal = QueryShot(origin, direction, maxDist, [radius], [playerId])

Arguments  
origin (TVec) - Shot ray origin as world space vector  
direction (TVec) - Unit length direction as world space vector  
maxDist (number) - Shot maximum distance. Keep this as low as possible for good performance.  
radius (number, optional) - Ray thickness. Default zero.  
playerId (number, optional) - Instigating player, will be ignored during hit detection.  


Return value  
didHit (bool) - If it was a valid hit.  
dist (number) - Distance along direction where the hit was registered.  
shape (number) - Handle to hit shape, zero if it did not hit a shape  
playerId (number) - PlayerId of hit player, zero if it did not hit a player  
playerDamageFactor (number) - 1.0 for a hit on the torso, and less for a lower body hit. Applicable only if a player was hit. Use this to scale the damage.  
normal (Vec) - Normal vector of the hit  


Test to see if a projectile would hit a shape or a player. It will return either a valid shape ID, player ID or none. 
    
    
    -- Note: 'shape' and 'player' are IDs/handles (numbers), not object references.
    function server.tick()
    
    	for p in Players() do
    		if InputPressed("usetool", p) then
    
    			local pos = GetPlayerEyeTransform(p).pos
    			local dir = TransformToParentVec(GetPlayerEyeTransform(p), Vec(0, 0, -1))
    
    			local hit, dist, shape, player, hitFactor, normal = QueryShot(pos, dir, 100, 0, p)
    			if hit then
    				if player then
    					DebugPrint("Hit player " .. GetPlayerName(player) .. " with damage factor " .. hitFactor)
    					ApplyPlayerDamage(player, 0.2 * hitFactor, "SuperGun", p)
    				elseif shape then
    					DebugPrint("Hit shape " .. shape .. " at distance " .. dist)
    					local body = GetShapeBody(shape)
    					local impPos = VecAdd(pos, VecScale(dir, dist))
    					local imp = Vec(100, 0, 0)
    					ApplyBodyImpulse(body, impPos, imp)
    				end
    			else
    				DebugPrint("No hit")
    			end
    		end
    	end
    end
    
    

* * *

### QueryClosestPoint 
    
    
    hit, point, normal, shape = QueryClosestPoint(origin, maxDist)

Arguments  
origin (TVec) - World space point  
maxDist (number) - Maximum distance. Keep this as low as possible for good performance.  


Return value  
hit (boolean) - True if a point was found  
point (TVec) - World space closest point  
normal (TVec) - World space normal at closest point  
shape (number) - Handle to closest shape  


This will query the closest point to all shapes in the world. If you want to set up a filter for the query you need to do so before every call to this function. 
    
    
    function client.tick()
    	local vehicle = FindVehicle("vehicle")
    	--Find closest point within 10 meters of {0, 5, 0}, excluding any point on myVehicle
    	QueryRejectVehicle(vehicle)
    	local hit, p, n, s = QueryClosestPoint(Vec(0, 5, 0), 10)
    	if hit then
    		DebugPrint(p)
    	end
    end
    
    

* * *

### QueryAabbShapes 
    
    
    list = QueryAabbShapes(min, max)

Arguments  
min (TVec) - Aabb minimum point  
max (TVec) - Aabb maximum point  


Return value  
list (table) - Indexed table with handles to all shapes in the aabb  


Return all shapes within the provided world space, axis-aligned bounding box 
    
    
    function client.tick()
    	local list = QueryAabbShapes(Vec(0, 0, 0), Vec(10, 10, 10))
    	for i=1, #list do
    		local shape = list[i]
    		DebugPrint(shape)
    	end
    end
    
    

* * *

### QueryAabbBodies 
    
    
    list = QueryAabbBodies(min, max)

Arguments  
min (TVec) - Aabb minimum point  
max (TVec) - Aabb maximum point  


Return value  
list (table) - Indexed table with handles to all bodies in the aabb  


Return all bodies within the provided world space, axis-aligned bounding box 
    
    
    function client.tick()
    	local list = QueryAabbBodies(Vec(0, 0, 0), Vec(10, 10, 10))
    	for i=1, #list do
    		local body = list[i]
    		DebugPrint(body)
    	end
    end
    
    

* * *

### QueryPath 
    
    
    QueryPath(start, end, [maxDist], [targetRadius], [type])

Arguments  
start (TVec) - World space start point  
end (TVec) - World space target point  
maxDist (number, optional) - Maximum path length before giving up. Default is infinite.  
targetRadius (number, optional) - Maximum allowed distance to target in meters. Default is 2.0  
type (string, optional) - Type of path. Can be "low", "standart", "water", "flying". Default is "standart"  


Return value  
none

Initiate path planning query. The result will run asynchronously as long as GetPathState returns "busy". An ongoing path query can be aborted with AbortPath. The path planning query will use the currently set up query filter, just like the other query functions. Using the 'water' type allows you to build a path within the water. The 'flying' type builds a path in the entire three-dimensional space. 
    
    
    function client.init()
    	QueryPath(Vec(-10, 0, 0), Vec(10, 0, 0))
    end
    
    

* * *

### CreatePathPlanner 
    
    
    id = CreatePathPlanner()

Arguments  
none

Return value  
id (number) - Path planner id  


Creates a new path planner that can be used to calculate multiple paths in parallel. It is supposed to be used together with PathPlannerQuery. Returns created path planner id/handler. It is recommended to reuse previously created path planners, because they exist throughout the lifetime of the script. 
    
    
    local paths = {}
    
    function server.init()
    	paths[1] = {
    		id = CreatePathPlanner(),
    		location = GetProperty(FindEntity("loc1", true), "transform").pos,
    	}
    
    	paths[2] = {
    		id = CreatePathPlanner(),
    		location = GetProperty(FindEntity("loc2", true), "transform").pos,
    	}
    
    	for i = 1, #paths do
    		PathPlannerQuery(paths[i].id, GetPlayerTransform().pos, paths[i].location)
    	end
    end
    
    

* * *

### DeletePathPlanner 
    
    
    DeletePathPlanner(id)

Arguments  
id (number) - Path planner id  


Return value  
none

Deletes the path planner with the specified id which can be used to save some memory. Calling CreatePathPlanner again can initialize a new path planner with the id previously deleted. 
    
    
    local paths = {}
    
    function server.init()
    	local id = CreatePathPlanner()
    	DeletePathPlanner(id)
    	-- now calling PathPlannerQuery for 'id' will result in an error
    end
    
    

* * *

### PathPlannerQuery 
    
    
    PathPlannerQuery(id, start, end, [maxDist], [targetRadius], [type])

Arguments  
id (number) - Path planner id  
start (TVec) - World space start point  
end (TVec) - World space target point  
maxDist (number, optional) - Maximum path length before giving up. Default is infinite.  
targetRadius (number, optional) - Maximum allowed distance to target in meters. Default is 2.0  
type (string, optional) - Type of path. Can be "low", "standart", "water", "flying". Default is "standart"  


Return value  
none

It works similarly to QueryPath but several paths can be built simultaneously within the same script. The QueryPath automatically creates a path planner with an index of 0 and only works with it. 
    
    
    local paths = {}
    
    function server.init()
    	paths[1] = {
    		id = CreatePathPlanner(),
    		location = GetProperty(FindEntity("loc1", true), "transform").pos,
    	}
    
    	paths[2] = {
    		id = CreatePathPlanner(),
    		location = GetProperty(FindEntity("loc2", true), "transform").pos,
    	}
    
    	for i = 1, #paths do
    		PathPlannerQuery(paths[i].id, GetPlayerTransform().pos, paths[i].location)
    	end
    end
    
    

* * *

### AbortPath 
    
    
    AbortPath([id])

Arguments  
id (number, optional) - Path planner id. Default value is 0.  


Return value  
none

Abort current path query, regardless of what state it is currently in. This is a way to save computing resources if the result of the current query is no longer of interest. 
    
    
    function server.init()
    	QueryPath(Vec(-10, 0, 0), Vec(10, 0, 0))
    	AbortPath()
    end
    
    

* * *

### GetPathState 
    
    
    state = GetPathState([id])

Arguments  
id (number, optional) - Path planner id. Default value is 0.  


Return value  
state (string) - Current path planning state  


Return the current state of the last path planning query.  State |  Description  
---|---  
idle |  No recent query  
busy |  Busy computing. No path found yet.  
fail |  Failed to find path. You can still get the resulting path (even though it won't reach the target).  
done |  Path planning completed and a path was found. Get it with GetPathLength and GetPathPoint)  
      
    
    function server.init()
    	QueryPath(Vec(-10, 0, 0), Vec(10, 0, 0))
    end
    
    function server.tick()
    	local s = GetPathState()
    	if s == "done" then
    		DebugPrint("done")
    	end
    end
    
    

* * *

### GetPathLength 
    
    
    length = GetPathLength([id])

Arguments  
id (number, optional) - Path planner id. Default value is 0.  


Return value  
length (number) - Length of last path planning result (in meters)  


Return the path length of the most recently computed path query. Note that the result can often be retrieved even if the path query failed. If the target point couldn't be reached, the path endpoint will be the point closest to the target. 
    
    
    function server.init()
    	QueryPath(Vec(-10, 0, 0), Vec(10, 0, 0))
    end
    
    function server.tick()
    	local s = GetPathState()
    	if s == "done" then
    		DebugPrint("done " .. GetPathLength())
    	end
    end
    
    

* * *

### GetPathPoint 
    
    
    point = GetPathPoint(dist, [id])

Arguments  
dist (number) - The distance along path. Should be between zero and result from GetPathLength()  
id (number, optional) - Path planner id. Default value is 0.  


Return value  
point (TVec) - The path point dist meters along the path  


Return a point along the path for the most recently computed path query. Note that the result can often be retrieved even if the path query failed. If the target point couldn't be reached, the path endpoint will be the point closest to the target. 
    
    
    function client.init()
    	QueryPath(Vec(-10, 0, 0), Vec(10, 0, 0))
    end
    
    function client.tick()
    	local d = 0
    	local l = GetPathLength()
    	while d < l do
    		DebugCross(GetPathPoint(d))
    		d = d + 0.5
    	end
    end
    
    

* * *

### GetLastSound 
    
    
    volume, position = GetLastSound()

Arguments  
none

Return value  
volume (number) - Volume of loudest sound played last frame  
position (TVec) - World position of loudest sound played last frame  

    
    
    function client.tick()
    	local vol, pos = GetLastSound()
    	if vol > 0 then
    		DebugPrint(vol .. " " .. VecStr(pos))
    	end
    end
    
    

* * *

### IsPointInWater 
    
    
    inWater, depth = IsPointInWater(point)

Arguments  
point (TVec) - World point as vector  


Return value  
inWater (boolean) - True if point is in water  
depth (number) - Depth of point into water, or zero if not in water  

    
    
    function client.tick()
    	local wet, d = IsPointInWater(Vec(10, 0, 0))
    	if wet then
    		DebugPrint("point" .. d .. " meters into water")
    	end
    end
    
    

* * *

### GetWindVelocity 
    
    
    vel = GetWindVelocity(point)

Arguments  
point (TVec) - World point as vector  


Return value  
vel (TVec) - Wind at provided position  


Get the wind velocity at provided point. The wind will be determined by wind property of the environment, but it varies with position procedurally. 
    
    
    function client.tick()
    	local v = GetWindVelocity(Vec(0, 10, 0))
    	DebugPrint(VecStr(v))
    end
    
    

* * *

### ParticleReset 
    
    
    ParticleReset()

Arguments  
none

Return value  
none

Reset to default particle state, which is a plain, white particle of radius 0.5. Collision is enabled and it alpha animates from 1 to 0. 
    
    
    function client.init()
    	ParticleReset()
    end
    
    

* * *

### ParticleType 
    
    
    ParticleType(type)

Arguments  
type (string) - Type of particle. Can be "smoke" or "plain".  


Return value  
none

Set type of particle 
    
    
    function client.init()
    	ParticleType("smoke")
    end
    
    

* * *

### ParticleTile 
    
    
    ParticleTile(type)

Arguments  
type (number) - Tile in the particle texture atlas (0-15)  


Return value  
none
    
    
    function client.init()
    	--Smoke particle
    	ParticleTile(0)
    
    	--Fire particle
    	ParticleTile(5)
    end
    
    

* * *

### ParticleColor 
    
    
    ParticleColor(r0, g0, b0, [r1], [g1], [b1])

Arguments  
r0 (number) - Red value  
g0 (number) - Green value  
b0 (number) - Blue value  
r1 (number, optional) - Red value at end  
g1 (number, optional) - Green value at end  
b1 (number, optional) - Blue value at end  


Return value  
none

Set particle color to either constant (three arguments) or linear interpolation (six arguments) 
    
    
    function client.init()
    	--Constant red
    	ParticleColor(1,0,0)
    
    	--Animating from yellow to red
    	ParticleColor(1,1,0, 1,0,0)
    end
    
    

* * *

### ParticleRadius 
    
    
    ParticleRadius(r0, [r1], [interpolation], [fadein], [fadeout])

Arguments  
r0 (number) - Radius  
r1 (number, optional) - End radius  
interpolation (string, optional) - Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.  
fadein (number, optional) - Fade in between t=0 and t=fadein. Default is zero.  
fadeout (number, optional) - Fade out between t=fadeout and t=1. Default is one.  


Return value  
none

Set the particle radius. Max radius for smoke particles is 1.0. 
    
    
    function client.init()
    	--Constant radius 0.4 meters
    	ParticleRadius(0.4)
    
    	--Interpolate from small to large
    	ParticleRadius(0.1, 0.7)
    end
    
    

* * *

### ParticleAlpha 
    
    
    ParticleAlpha(a0, [a1], [interpolation], [fadein], [fadeout])

Arguments  
a0 (number) - Alpha (0.0 - 1.0)  
a1 (number, optional) - End alpha (0.0 - 1.0)  
interpolation (string, optional) - Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.  
fadein (number, optional) - Fade in between t=0 and t=fadein. Default is zero.  
fadeout (number, optional) - Fade out between t=fadeout and t=1. Default is one.  


Return value  
none

Set the particle alpha (opacity). 
    
    
    function client.init()
    	--Interpolate from opaque to transparent
    	ParticleAlpha(1.0, 0.0)
    end
    
    

* * *

### ParticleGravity 
    
    
    ParticleGravity(g0, [g1], [interpolation], [fadein], [fadeout])

Arguments  
g0 (number) - Gravity  
g1 (number, optional) - End gravity  
interpolation (string, optional) - Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.  
fadein (number, optional) - Fade in between t=0 and t=fadein. Default is zero.  
fadeout (number, optional) - Fade out between t=fadeout and t=1. Default is one.  


Return value  
none

Set particle gravity. It will be applied along the world Y axis. A negative value will move the particle downwards. 
    
    
    function client.init()
    	--Move particles slowly upwards
    	ParticleGravity(2)
    end
    
    

* * *

### ParticleDrag 
    
    
    ParticleDrag(d0, [d1], [interpolation], [fadein], [fadeout])

Arguments  
d0 (number) - Drag  
d1 (number, optional) - End drag  
interpolation (string, optional) - Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.  
fadein (number, optional) - Fade in between t=0 and t=fadein. Default is zero.  
fadeout (number, optional) - Fade out between t=fadeout and t=1. Default is one.  


Return value  
none

Particle drag will slow down fast moving particles. It's implemented slightly different for smoke and plain particles. Drag must be positive, and usually look good between zero and one. 
    
    
    function client.init()
    	--Slow down fast moving particles
    	ParticleDrag(0.5)
    end
    
    

* * *

### ParticleEmissive 
    
    
    ParticleEmissive(d0, [d1], [interpolation], [fadein], [fadeout])

Arguments  
d0 (number) - Emissive  
d1 (number, optional) - End emissive  
interpolation (string, optional) - Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.  
fadein (number, optional) - Fade in between t=0 and t=fadein. Default is zero.  
fadeout (number, optional) - Fade out between t=fadeout and t=1. Default is one.  


Return value  
none

Draw particle as emissive (glow in the dark). This is useful for fire and embers. 
    
    
    function client.init()
    	--Highly emissive at start, not emissive at end
    	ParticleEmissive(5, 0)
    end
    
    

* * *

### ParticleRotation 
    
    
    ParticleRotation(r0, [r1], [interpolation], [fadein], [fadeout])

Arguments  
r0 (number) - Rotation speed in radians per second.  
r1 (number, optional) - End rotation speed in radians per second.  
interpolation (string, optional) - Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.  
fadein (number, optional) - Fade in between t=0 and t=fadein. Default is zero.  
fadeout (number, optional) - Fade out between t=fadeout and t=1. Default is one.  


Return value  
none

Makes the particle rotate. Positive values is counter-clockwise rotation. 
    
    
    function client.init()
    	--Rotate fast at start and slow at end
    	ParticleRotation(10, 1)
    end
    
    

* * *

### ParticleStretch 
    
    
    ParticleStretch(s0, [s1], [interpolation], [fadein], [fadeout])

Arguments  
s0 (number) - Stretch  
s1 (number, optional) - End stretch  
interpolation (string, optional) - Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.  
fadein (number, optional) - Fade in between t=0 and t=fadein. Default is zero.  
fadeout (number, optional) - Fade out between t=fadeout and t=1. Default is one.  


Return value  
none

Stretch particle along with velocity. 0.0 means no stretching. 1.0 stretches with the particle motion over one frame. Larger values stretches the particle even more. 
    
    
    function client.init()
    	--Stretch particle along direction of motion
    	ParticleStretch(1.0)
    end
    
    

* * *

### ParticleSticky 
    
    
    ParticleSticky(s0, [s1], [interpolation], [fadein], [fadeout])

Arguments  
s0 (number) - Sticky (0.0 - 1.0)  
s1 (number, optional) - End sticky (0.0 - 1.0)  
interpolation (string, optional) - Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.  
fadein (number, optional) - Fade in between t=0 and t=fadein. Default is zero.  
fadeout (number, optional) - Fade out between t=fadeout and t=1. Default is one.  


Return value  
none

Make particle stick when in contact with objects. This can be used for friction. 
    
    
    function client.init()
    	--Make particles stick to objects
    	ParticleSticky(0.5)
    end
    
    

* * *

### ParticleCollide 
    
    
    ParticleCollide(c0, [c1], [interpolation], [fadein], [fadeout])

Arguments  
c0 (number) - Collide (0.0 - 1.0)  
c1 (number, optional) - End collide (0.0 - 1.0)  
interpolation (string, optional) - Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.  
fadein (number, optional) - Fade in between t=0 and t=fadein. Default is zero.  
fadeout (number, optional) - Fade out between t=fadeout and t=1. Default is one.  


Return value  
none

Control particle collisions. A value of zero means that collisions are ignored. One means full collision. It is sometimes useful to animate this value from zero to one in order to not collide with objects around the emitter. 
    
    
    function client.init()
    	--Disable collisions
    	ParticleCollide(0)
    
    	--Enable collisions over time
    	ParticleCollide(0, 1)
    
    	--Ramp up collisions very quickly, only skipping the first 5% of lifetime
    	ParticleCollide(1, 1, "constant", 0.05)
    end
    
    

* * *

### ParticleFlags 
    
    
    ParticleFlags(bitmask)

Arguments  
bitmask (number) - Particle flags (bitmask 0-65535)  


Return value  
none

Set particle bitmask. The value 256 means fire extinguishing particles and is currently the only flag in use. There might be support for custom flags and queries in the future. 
    
    
    function client.tick()
    	--Fire extinguishing particle
    	ParticleFlags(256)
    	SpawnParticle(Vec(0, 10, 0), -0.1, math.random() + 1)
    end
    
    

* * *

### SpawnParticle 
    
    
    SpawnParticle(pos, velocity, lifetime)

Arguments  
pos (TVec) - World space point as vector  
velocity (TVec) - World space velocity as vector  
lifetime (number) - Particle lifetime in seconds  


Return value  
none

Spawn particle using the previously set up particle state. You can call this multiple times using the same particle state, but with different position, velocity and lifetime. You can also modify individual properties in the particle state in between calls to to this function. 
    
    
    function client.tick()
    	ParticleReset()
    	ParticleType("smoke")
    	ParticleColor(0.7, 0.6, 0.5)
    	--Spawn particle at world origo with upwards velocity and a lifetime of ten seconds
    	SpawnParticle(Vec(0, 5, 0), Vec(0, 1, 0), 10.0)
    end
    
    

* * *

### Spawn 
    
    
    entities = Spawn(xml, transform, [allowStatic], [jointExisting])

Arguments  
xml (string) - File name or xml string  
transform (TTransform) - Spawn transform  
allowStatic (boolean, optional) - Allow spawning static shapes and bodies (default false)  
jointExisting (boolean, optional) - Allow joints to connect to existing scene geometry (default false)  


Return value  
entities (table) - Indexed table with handles to all spawned entities  


The first argument can be either a prefab XML file in your mod folder or a string with XML content. It is also possible to spawn prefabs from other mods, by using the mod id followed by colon, followed by the prefab path. Spawning prefabs from other mods should be used with causion since the referenced mod might not be installed. 
    
    
    function server.init()
    	Spawn("MOD/prefab/mycar.xml", Transform(Vec(0, 5, 0)))
    	Spawn("<voxbox size='10 10 10' prop='true' material='wood'/>", Transform(Vec(0, 10, 0)))
    end
    
    

* * *

### SpawnLayer 
    
    
    entities = SpawnLayer(xml, layer, transform, [allowStatic], [jointExisting])

Arguments  
xml (string) - File name or xml string  
layer (string) - Vox layer name  
transform (TTransform) - Spawn transform  
allowStatic (boolean, optional) - Allow spawning static shapes and bodies (default false)  
jointExisting (boolean, optional) - Allow joints to connect to existing scene geometry (default false)  


Return value  
entities (table) - Indexed table with handles to all spawned entities  


Same functionality as Spawn(), except using a specific layer in the vox-file 
    
    
    function server.init()
    	Spawn("MOD/prefab/mycar.xml", "some_vox_layer", Transform(Vec(0, 5, 0)))
    	Spawn("<voxbox size='10 10 10' prop='true' material='wood'/>", "some_vox_layer", Transform(Vec(0, 10, 0)))
    end
    
    

* * *

### SpawnTool 
    
    
    entities = SpawnTool(id, transform, [allowStatic], [voxScale])

Arguments  
id (string) - Tool ID  
transform (TTransform) - Spawn transform  
allowStatic (boolean, optional) - Allow spawning static shapes and bodies (default false)  
voxScale (number, optional) - Applies a scale to voxels (default 1.0)  


Return value  
entities (table) - Indexed table with handles to all spawned entities  

    
    
    function server.init()
    	SpawnTool("sledge", Transform(Vec(0, 5, 0)))
    end
    
    

* * *

### AddMapMarker CLIENT ONLY
    
    
    AddMapMarker(id, tag, name, category, showLabelOnMap, info, pos, color, [infoImage], [dotIcon])

Arguments  
id (number) - An id to identify the marker, typically player ID or body ID.  
tag (string) - A tag to help distinguish markers.  
name (string) - Name of the marker.  
category (string) - Used to group markers together in map target list.  
showLabelOnMap (bool) - name label will be shown on map if true  
info (string) - Additional information about the marker, displayed when selected.  
pos (Vec) - The world position of the marker.  
color (Vec) - The color of the marker, as a Vec table (e.g. Vec(1, 0, 0) for red)  
infoImage (string, optional) - Path to the image to be displayed in the info section.  
dotIcon (string, optional) - Path to the image used to represent the marker on map.  


Return value  
none

Adds a marker on the map with the provided info. 
    
    
    function client.tick()
    	AddMapMarker(1, "bonusTarget", "Bonus Target", "One of a kind", Vec(30, 40, 50), Vec(1,0,0), "MOD/gfx/bonus_info.png", "MOD/gfx/bonus_icon.png")
    end
    
    

* * *

### SelectedMapMarker CLIENT ONLY
    
    
    id, tag = SelectedMapMarker()

Arguments  
none

Return value  
id (number) - id of map marker that was selected this tick.  
tag (string) - the corresponding tag.  

    
    
    function client.tick()
    	AddMapMarker(1, "bonusTarget", "Bonus Target", "One of a kind", Vec(30, 40, 50), Vec(1,0,0), "MOD/gfx/bonus_info.png", "MOD/gfx/bonus_icon.png")
    
    	local id, tag = SelectedMapMarker()
    
    	if id == 1 and tag == "bonusTarget" then
    		DebugPrint("You selected the Bonus Target on the map!")
    	end
    end
    
    

* * *

### Shoot SERVER ONLY
    
    
    Shoot(origin, direction, [type], [strength], [maxDist], [playerId])

Arguments  
origin (TVec) - Origin in world space as vector  
direction (TVec) - Unit length direction as world space vector  
type (string, optional) - Shot type, see description, default is "bullet"  
strength (number, optional) - Strength scaling, default is 1.0  
maxDist (number, optional) - Maximum distance, default is 100.0  
playerId (number, optional) - Instigating player. Can be skipped for non-player shots (helicopters etc.)  


Return value  
none

Fire projectile. Type can be one of "bullet", "rocket", "gun" or "shotgun". For backwards compatilbility, type also accept a number, where 1 is same as "rocket" and anything else "bullet" Note that this function will only spawn the projectile, not make any sound. 
    
    
    function server.tick()
    	Shoot(Vec(0, 10, 0), Vec(0, -1, 0), "shotgun")
    end
    
    

* * *

### Paint SERVER ONLY
    
    
    Paint(origin, radius, [type], [probability])

Arguments  
origin (TVec) - Origin in world space as vector  
radius (number) - Affected radius, in range 0.0 to 5.0  
type (string, optional) - Paint type. Can be "explosion" or "spraycan". Default is spraycan.  
probability (number, optional) - Dithering probability between zero and one, default is 1.0  


Return value  
none

Tint the color of objects within radius to either black or yellow. 
    
    
    function server.tick()
    	Paint(Vec(0, 2, 0), 5.0, "spraycan")
    end
    
    

* * *

### PaintRGBA SERVER ONLY
    
    
    PaintRGBA(origin, radius, red, green, blue, [alpha], [probability])

Arguments  
origin (TVec) - Origin in world space as vector  
radius (number) - Affected radius, in range 0.0 to 5.0  
red (number) - red color value, in range 0.0 to 1.0  
green (number) - green color value, in range 0.0 to 1.0  
blue (number) - blue color value, in range 0.0 to 1.0  
alpha (number, optional) - alpha channel value, in range 0.0 to 1.0  
probability (number, optional) - Dithering probability between zero and one, default is 1.0  


Return value  
none

Tint the color of objects within radius to custom RGBA color. 
    
    
    function server.tick()
    	PaintRGBA(Vec(0, 5, 0), 5.5, 1.0, 0.0, 0.0)
    end
    
    

* * *

### MakeHole SERVER ONLY
    
    
    count = MakeHole(position, r0, [r1], [r2], [silent])

Arguments  
position (TVec) - Hole center point  
r0 (number) - Hole radius for soft materials  
r1 (number, optional) - Hole radius for medium materials. May not be bigger than r0. Default zero.  
r2 (number, optional) - Hole radius for hard materials. May not be bigger than r1. Default zero.  
silent (boolean, optional) - Make hole without playing any break sounds.  


Return value  
count (number) - Number of voxels that was cut out. This will be zero if there were no changes to any shape.  


Make a hole in the environment. Radius is given in meters. Soft materials: glass, foliage, dirt, wood, plaster and plastic. Medium materials: concrete, brick and weak metal. Hard materials: hard metal and hard masonry. 
    
    
    function server.init()
    	MakeHole(Vec(0, 0, 0), 5.0, 1.0)
    end
    
    

* * *

### Explosion SERVER ONLY
    
    
    Explosion(pos, size, [instigatingPlayerId])

Arguments  
pos (TVec) - Position in world space as vector  
size (number) - Explosion size from 0.5 to 4.0  
instigatingPlayerId (number, optional) - Instigating player ID.  


Return value  
none
    
    
    function server.init()
    	Explosion(Vec(0, 5, 0), 1)
    end
    
    

* * *

### SpawnFire SERVER ONLY
    
    
    SpawnFire(pos)

Arguments  
pos (TVec) - Position in world space as vector  


Return value  
none
    
    
    function server.tick()
    	SpawnFire(Vec(0, 2, 0))
    end
    
    

* * *

### GetFireCount 
    
    
    count = GetFireCount()

Arguments  
none

Return value  
count (number) - Number of active fires in level  

    
    
    function client.tick()
    	local c = GetFireCount()
    	DebugPrint("Fire count " .. c)
    end
    
    

* * *

### QueryClosestFire 
    
    
    hit, pos = QueryClosestFire(origin, maxDist)

Arguments  
origin (TVec) - World space position as vector  
maxDist (number) - Maximum search distance  


Return value  
hit (boolean) - A fire was found within search distance  
pos (TVec) - Position of closest fire  

    
    
    function client.tick()
    	local hit, pos = QueryClosestFire(GetPlayerTransform().pos, 5.0)
    	if hit then
    		--There is a fire within 5 meters to the player. Mark it with a debug cross.
    		DebugCross(pos)
    	end
    end
    
    

* * *

### QueryAabbFireCount 
    
    
    count = QueryAabbFireCount(min, max)

Arguments  
min (TVec) - Aabb minimum point  
max (TVec) - Aabb maximum point  


Return value  
count (number) - Number of active fires in bounding box  

    
    
    function client.tick()
    	local count = QueryAabbFireCount(Vec(0,0,0), Vec(10,10,10))
    	DebugPrint(count)
    end
    
    

* * *

### RemoveAabbFires SERVER ONLY
    
    
    count = RemoveAabbFires(min, max)

Arguments  
min (TVec) - Aabb minimum point  
max (TVec) - Aabb maximum point  


Return value  
count (number) - Number of fires removed  

    
    
    function server.tick()
    	local removedCount= RemoveAabbFires(Vec(0,0,0), Vec(10,10,10))
    	DebugPrint(removedCount)
    end
    
    

* * *

### GetCameraTransform CLIENT ONLY
    
    
    transform = GetCameraTransform()

Arguments  
none

Return value  
transform (TTransform) - Current camera transform  

    
    
    function client.tick()
    	local t = GetCameraTransform()
    	DebugPrint(TransformStr(t))
    end
    
    

* * *

### SetCameraTransform CLIENT ONLY
    
    
    SetCameraTransform(transform, [fov])

Arguments  
transform (TTransform) - Desired camera transform  
fov (number, optional) - Optional horizontal field of view in degrees (default: 90)  


Return value  
none

Override current camera transform for this frame. Call continuously to keep overriding. When transform of some shape or body used to calculate camera transform, consider use of AttachCameraTo, because you might be using transform from previous physics update (that was on previous frame or even earlier depending on fps and timescale). 
    
    
    function client.tick()
    	SetCameraTransform(Transform(Vec(0, 10, 0), QuatEuler(0, 90, 0)))
    end
    
    

* * *

### RequestFirstPerson CLIENT ONLY
    
    
    RequestFirstPerson(transition)

Arguments  
transition (boolean) - Use transition  


Return value  
none

Use this function to switch to first-person view, overriding the player's selected third-person view. This is particularly useful for scenarios like looking through a camera viewfinder or a rifle scope. Call the function continuously to maintain the override. 
    
    
    function client.tick()
    	if useViewFinder then
    		RequestFirstPerson(true)
    	end
    end
    
    function client.draw()
    	if useViewFinder and !GetBool("game.thirdperson") then
    		-- Draw view finder overlay
    	end
    end
    
    

* * *

### RequestThirdPerson CLIENT ONLY
    
    
    RequestThirdPerson(transition)

Arguments  
transition (boolean) - Use transition  


Return value  
none

Use this function to switch to third-person view, overriding the player's selected first-person view. Call the function continuously to maintain the override. 
    
    
    function client.tick()
    	if useThirdPerson then
    		RequestThirdPerson(true)
    	end
    end
    
    

* * *

### SetCameraOffsetTransform CLIENT ONLY
    
    
    SetCameraOffsetTransform(transform, [stackable])

Arguments  
transform (TTransform) - Desired camera offset transform  
stackable (boolean, optional) - True if camera offset should summ up with multiple calls per tick  


Return value  
none

Call this function continously to apply a camera offset. Can be used for camera effects such as shake and wobble. 
    
    
    function client.tick()
    	local tPosX = Transform(Vec(math.sin(GetTime()*3.0) * 0.2, 0, 0))
    	local tPosY = Transform(Vec(0, math.cos(GetTime()*3.0) * 0.2, 0), QuatAxisAngle(Vec(0, 0, 0)))
    
    	SetCameraOffsetTransform(tPosX, true)
    	SetCameraOffsetTransform(tPosY, true)
    end
    
    

* * *

### AttachCameraTo CLIENT ONLY
    
    
    AttachCameraTo(handle, [ignoreRotation])

Arguments  
handle (number) - Body or shape handle  
ignoreRotation (boolean, optional) - True to ignore rotation and use position only, false to use full transform  


Return value  
none

Attach current camera transform for this frame to body or shape. Call continuously to keep overriding. In tick function we have coordinates of bodies and shapes that are not yet updated by physics, that's why camera can not be in sync with it using SetCameraTransform, instead use this function and SetCameraOffsetTransform to place camera around any body or shape without lag. 
    
    
    function client.tick()
    	local vehicle = GetPlayerVehicle()
    	if vehicle ~= 0 then
    		AttachCameraTo(GetVehicleBody(vehicle))
    		SetCameraOffsetTransform(Transform(Vec(1, 2, 3)))
    	end
    end
    
    

* * *

### SetPivotClipBody CLIENT ONLY
    
    
    SetPivotClipBody(bodyHandle, mainShapeIdx)

Arguments  
bodyHandle (number) - Handle of a body, shapes of which should be  
mainShapeIdx (number) - Optional index of a shape among the given  


Return value  
none

treated as pivots when clipping body's shapes which is used to calculate clipping parameters (default: -1) Enforce camera clipping for this frame and mark the given body as a pivot for clipping. Call continuously to keep overriding. 
    
    
    local body_1 = 0
    local body_2 = 0
    function client.init()
    	body_1 = FindBody("body_1")
    	body_2 = FindBody("body_2")
    end
    
    function client.tick()
    	SetPivotClipBody(body_1, 0) -- this overload should be called once and
    	-- only once per frame to take effect
    	SetPivotClipBody(body_2)
    end
    
    

* * *

### ShakeCamera CLIENT ONLY
    
    
    ShakeCamera(strength)

Arguments  
strength (number) - Normalized strength of shaking  


Return value  
none

Shakes the player camera 
    
    
    function client.tick()
    	ShakeCamera(0.5)
    end
    
    

* * *

### SetCameraFov CLIENT ONLY
    
    
    SetCameraFov(degrees)

Arguments  
degrees (number) - Horizontal field of view in degrees (10-170)  


Return value  
none

Override field of view for the next frame for all camera modes, except when explicitly set in SetCameraTransform 
    
    
    function client.tick()
    	SetCameraFov(60)
    end
    
    

* * *

### SetCameraDof CLIENT ONLY
    
    
    SetCameraDof(distance, [amount])

Arguments  
distance (number) - Depth of field distance  
amount (number, optional) - Optional amount of blur (default 1.0)  


Return value  
none

Override depth of field for the next frame for all camera modes. Depth of field will be used even if turned off in options. 
    
    
    function client.tick()
    	--Set depth of field to 10 meters
    	SetCameraDof(10)
    end
    
    

* * *

### DisableMotionBlur CLIENT ONLY
    
    
    DisableMotionBlur()

Arguments  
none

Return value  
none

Disable motion blur for the current frame. 
    
    
    function client.tick()
    	--Disable motion blur to improve readability of certain game play elements.
    	DisableMotionBlur()
    end
    
    

* * *

### SetLowHealthBlurThreshold CLIENT ONLY
    
    
    SetLowHealthBlurThreshold(health)

Arguments  
health (number) - health value where anything lower results in blurred vision  


Return value  
none

Must be called every frame that one would like to alter this effect. Client-side only 
    
    
    function client.tick()
    	-- Don't show the blurry vision until the player's health drops below 0.4
    	SetLowHealthBlurThreshold(0.4)
    end
    
    

* * *

### PointLight 
    
    
    PointLight(pos, r, g, b, [intensity])

Arguments  
pos (TVec) - World space light position  
r (number) - Red  
g (number) - Green  
b (number) - Blue  
intensity (number, optional) - Intensity. Default is 1.0.  


Return value  
none

Add a temporary point light to the world for this frame. Call continuously for a steady light. 
    
    
    function client.tick()
    	--Pulsating, yellow light above world origo
    	local intensity = 3 + math.sin(GetTime())
    	PointLight(Vec(0, 5, 0), 1, 1, 0, intensity)
    end
    
    

* * *

### SetTimeScale SERVER ONLY
    
    
    SetTimeScale(scale)

Arguments  
scale (number) - Time scale 0.0 to 2.0  


Return value  
none

Experimental. Scale time in order to make a slow-motion or acceleration effect. Audio will also be affected. (v1.4 and below: this function will affect physics behavior and is not intended for gameplay purposes.) Starting from v1.5 this function does not affect physics behavior and rely on rendering interpolation. Scaling time up may decrease performance, and is not recommended for gameplay purposes. Calling this function will change time scale for the next frame only. Call every frame from tick function to get steady slow-motion. 
    
    
    function server.tick()
    	--Slow down time when holding down a key
    	if InputDown('t', hostPlayerId) then
    		SetTimeScale(0.2)
    	end
    end
    
    

* * *

### SetEnvironmentDefault SERVER ONLY
    
    
    SetEnvironmentDefault()

Arguments  
none

Return value  
none

Reset the environment properties to default. This is often useful before setting up a custom environment. 
    
    
    function server.init()
    	SetEnvironmentDefault()
    end
    
    

* * *

### SetEnvironmentProperty SERVER ONLY
    
    
    SetEnvironmentProperty(name, value0, [value1], [value2], [value3])

Arguments  
name (string) - Property name  
value0 (any) - Property value (type depends on property)  
value1 (any, optional) - Extra property value (only some properties)  
value2 (any, optional) - Extra property value (only some properties)  
value3 (any, optional) - Extra property value (only some properties)  


Return value  
none

This function is used for manipulating the environment properties. The available properties are exactly the same as in the editor, except for "snowonground" which is not currently supported. 
    
    
    function server.init()
    	SetEnvironmentDefault()
    	SetEnvironmentProperty("skybox", "cloudy.dds")
    	SetEnvironmentProperty("rain", 0.7)
    	SetEnvironmentProperty("fogcolor", 0.5, 0.5, 0.8)
    	SetEnvironmentProperty("nightlight", false)
    end
    
    

* * *

### GetEnvironmentProperty 
    
    
    value0, value1, value2, value3, value4 = GetEnvironmentProperty(name)

Arguments  
name (string) - Property name  


Return value  
value0 (any) - Property value (type depends on property)  
value1 (any) - Property value (only some properties)  
value2 (any) - Property value (only some properties)  
value3 (any) - Property value (only some properties)  
value4 (any) - Property value (only some properties)  


This function is used for querying the current environment properties. The available properties are exactly the same as in the editor. 
    
    
    function client.init()
    	local skyboxPath = GetEnvironmentProperty("skybox")
    	local rainValue = GetEnvironmentProperty("rain")
    	local r,g,b = GetEnvironmentProperty("fogcolor")
    	local enabled = GetEnvironmentProperty("nightlight")
    	DebugPrint(skyboxPath)
    	DebugPrint(rainValue)
    	DebugPrint(r .. " " .. g .. " " .. b)
    	DebugPrint(enabled)
    end
    
    

* * *

### SetPostProcessingDefault 
    
    
    SetPostProcessingDefault()

Arguments  
none

Return value  
none

Reset the post processing properties to default. 
    
    
    function client.tick()
    	SetPostProcessingProperty("saturation", 0.4)
    	SetPostProcessingProperty("colorbalance", 1.3, 1.0, 0.7)
    	SetPostProcessingDefault()
    end
    
    

* * *

### SetPostProcessingProperty 
    
    
    SetPostProcessingProperty(name, value0, [value1], [value2])

Arguments  
name (string) - Property name  
value0 (number) - Property value  
value1 (number, optional) - Extra property value (only some properties)  
value2 (number, optional) - Extra property value (only some properties)  


Return value  
none

This function is used for manipulating the post processing properties. The available properties are exactly the same as in the editor. 
    
    
    --Sepia post processing
    function client.tick()
    	SetPostProcessingProperty("saturation", 0.4)
    	SetPostProcessingProperty("colorbalance", 1.3, 1.0, 0.7)
    end
    
    

* * *

### GetPostProcessingProperty 
    
    
    value0, value1, value2 = GetPostProcessingProperty(name)

Arguments  
name (string) - Property name  


Return value  
value0 (number) - Property value  
value1 (number) - Property value (only some properties)  
value2 (number) - Property value (only some properties)  


This function is used for querying the current post processing properties. The available properties are exactly the same as in the editor. 
    
    
    function client.tick()
    	SetPostProcessingProperty("saturation", 0.4)
    	SetPostProcessingProperty("colorbalance", 1.3, 1.0, 0.7)
    	local saturation = GetPostProcessingProperty("saturation")
    	local r,g,b = GetPostProcessingProperty("colorbalance")
    	DebugPrint("saturation " .. saturation)
    	DebugPrint("colorbalance " .. r .. " " .. g .. " " .. b)
    end
    
    

* * *

### DrawLine 
    
    
    DrawLine(p0, p1, [r], [g], [b], [a])

Arguments  
p0 (TVec) - World space point as vector  
p1 (TVec) - World space point as vector  
r (number, optional) - Red  
g (number, optional) - Green  
b (number, optional) - Blue  
a (number, optional) - Alpha  


Return value  
none

Draw a 3D line. In contrast to DebugLine, it will not show behind objects. Default color is white. 
    
    
    
    function server.tick()
    	--Draw white debug line
    	DrawLine(Vec(0, 0, 0), Vec(-10, 5, -10))
    
    	--Draw red debug line
    	DrawLine(Vec(0, 0, 0), Vec(10, 5, 10), 1, 0, 0)
    end
    
    -- Or
    
    function client.tick()
    	--Draw white debug line
    	DrawLine(Vec(0, 0, 0), Vec(-10, 5, -10))
    
    	--Draw red debug line
    	DrawLine(Vec(0, 0, 0), Vec(10, 5, 10), 1, 0, 0)
    end
    
    

* * *

### DebugLine 
    
    
    DebugLine(p0, p1, [r], [g], [b], [a])

Arguments  
p0 (TVec) - World space point as vector  
p1 (TVec) - World space point as vector  
r (number, optional) - Red  
g (number, optional) - Green  
b (number, optional) - Blue  
a (number, optional) - Alpha  


Return value  
none

Draw a 3D debug overlay line in the world. Default color is white. 
    
    
    
    function server.tick()
    	--Draw white debug line
    	DebugLine(Vec(0, 0, 0), Vec(-10, 5, -10))
    
    	--Draw red debug line
    	DebugLine(Vec(0, 0, 0), Vec(10, 5, 10), 1, 0, 0)
    end
    
    -- Or
    
    function client.tick()
    	--Draw white debug line
    	DebugLine(Vec(0, 0, 0), Vec(-10, 5, -10))
    
    	--Draw red debug line
    	DebugLine(Vec(0, 0, 0), Vec(10, 5, 10), 1, 0, 0)
    end
    
    
    

* * *

### DebugCross 
    
    
    DebugCross(p0, [r], [g], [b], [a])

Arguments  
p0 (TVec) - World space point as vector  
r (number, optional) - Red  
g (number, optional) - Green  
b (number, optional) - Blue  
a (number, optional) - Alpha  


Return value  
none

Draw a debug cross in the world to highlight a location. Default color is white. 
    
    
    function server.tick()
    	DebugCross(Vec(10, 5, 5))
    end
    -- Or
    function client.tick()
    	DebugCross(Vec(10, 5, 5))
    end
    
    

* * *

### DebugTransform 
    
    
    DebugTransform(transform, [scale])

Arguments  
transform (TTransform) - The transform  
scale (number, optional) - Length of the axis  


Return value  
none

Draw the axis of the transform 
    
    
    function server.tick()
    	DebugTransform(GetPlayerCameraTransform(), 0.5)
    end
    -- Or
    function client.tick()
    	DebugTransform(GetPlayerCameraTransform(), 0.5)
    end
    
    

* * *

### DebugWatch 
    
    
    DebugWatch(name, value, [lineWrapping])

Arguments  
name (string) - Name  
value (any) - Value  
lineWrapping (boolean, optional) - True if you need to wrap Table lines. Works only with tables.  


Return value  
none

Show a named valued on screen for debug purposes. Up to 32 values can be shown simultaneously. Values updated the current frame are drawn opaque. Old values are drawn transparent in white. 

The function will also recognize tables and convert them to strings automatically. 
    
    
    function client.tick()
    	DebugWatch("Player camera transform", GetPlayerCameraTransform())
    
    	local anyTable = {
    		"teardown",
    		{
    			name = "Alex",
    			age = 25,
    			child = { name = "Lena" }
    		},
    		nil,
    		version = "1.6.0",
    		true
    	}
    	DebugWatch("table", anyTable);
    end
    
    

* * *

### DebugPrint 
    
    
    DebugPrint(message, [lineWrapping])

Arguments  
message (string) - Message to display  
lineWrapping (boolean, optional) - True if you need to wrap Table lines. Works only with tables.  


Return value  
none

Display message on screen. The last 20 lines are displayed. The function will also recognize tables and convert them to strings automatically. 
    
    
    function client.init()
    	DebugPrint("time")
    
    	DebugPrint(GetPlayerCameraTransform())
    
    	local anyTable = {
    		"teardown",
    		{
    			name = "Alex",
    			age = 25,
    			child = { name = "Lena" }
    		},
    		nil,
    		version = "1.6.0",
    		true,
    	}
    	DebugPrint(anyTable)
    end
    
    

* * *

### RegisterListenerTo 
    
    
    RegisterListenerTo(eventName, listenerFunction)

Arguments  
eventName (string) - Event name  
listenerFunction (string) - Listener function name  


Return value  
none

Binds the callback function on the event This function is deprecated. Use the event system instead. **This function will be deprecated in the next update!**  

    
    
    function onLangauageChanged()
    	DebugPrint("langauageChanged")
    end
    
    function client.init()
    	RegisterListenerTo("LanguageChanged", "onLangauageChanged")
    	TriggerEvent("LanguageChanged")
    end
    
    

* * *

### UnregisterListener 
    
    
    UnregisterListener(eventName, listenerFunction)

Arguments  
eventName (string) - Event name  
listenerFunction (string) - Listener function name  


Return value  
none

Unbinds the callback function from the event This function is deprecated. Use the event system instead. **This function will be deprecated in the next update!**  

    
    
    function onLangauageChanged()
    	DebugPrint("langauageChanged")
    end
    
    function client.init()
    	RegisterListenerTo("LanguageChanged", "onLangauageChanged")
    	UnregisterListener("LanguageChanged", "onLangauageChanged")
    	TriggerEvent("LanguageChanged")
    end
    
    

* * *

### TriggerEvent 
    
    
    TriggerEvent(eventName, [args])

Arguments  
eventName (string) - Event name  
args (string, optional) - Event parameters  


Return value  
none

Triggers an event for all registered listeners This function is deprecated. Use the event system instead. **This function will be deprecated in the next update!**  

    
    
    function onLangauageChanged()
    	DebugPrint("langauageChanged")
    end
    
    function client.init()
    	RegisterListenerTo("LanguageChanged", "onLangauageChanged")
    	UnregisterListener("LanguageChanged", "onLangauageChanged")
    	TriggerEvent("LanguageChanged")
    end
    
    

* * *

### LoadHaptic CLIENT ONLY
    
    
    handle = LoadHaptic(filepath)

Arguments  
filepath (string) - Path to Haptic effect to play  


Return value  
handle (string) - Haptic effect handle  

    
    
    -- Rumble with gun Haptic effect
    function client.init()
    	haptic_effect = LoadHaptic("haptic/gun_fire.xml")
    end
    
    function client.tick()
    	if trigHaptic then
    		PlayHaptic(haptic_effect, 1)
    	end
    end
    
    

* * *

### CreateHaptic CLIENT ONLY
    
    
    handle = CreateHaptic(leftMotorRumble, rightMotorRumble, leftTriggerRumble, rightTriggerRumble)

Arguments  
leftMotorRumble (number) - Amount of rumble for left motor  
rightMotorRumble (number) - Amount of rumble for right motor  
leftTriggerRumble (number) - Amount of rumble for left trigger  
rightTriggerRumble (number) - Amount of rumble for right trigger  


Return value  
handle (string) - Haptic effect handle  

    
    
    -- Rumble with gun Haptic effect
    function client.init()
    	haptic_effect = CreateHaptic(1, 1, 0, 0)
    end
    
    function client.tick()
    	if trigHaptic then
    		PlayHaptic(haptic_effect, 1)
    	end
    end
    
    

* * *

### PlayHaptic CLIENT ONLY
    
    
    PlayHaptic(handle, amplitude)

Arguments  
handle (string) - Handle of haptic effect  
amplitude (number) - Amplidute used for calculation of Haptic effect.  


Return value  
none

If Haptic already playing, restarts it. 
    
    
    -- Rumble with gun Haptic effect
    function client.init()
    	haptic_effect = LoadHaptic("haptic/gun_fire.xml")
    end
    
    function client.tick()
    	if trigHaptic then
    		PlayHaptic(haptic_effect, 1)
    	end
    end
    
    

* * *

### PlayHapticDirectional CLIENT ONLY
    
    
    PlayHapticDirectional(handle, direction, amplitude)

Arguments  
handle (string) - Handle of haptic effect  
direction (TVec) - Direction in which effect must be played  
amplitude (number) - Amplidute used for calculation of Haptic effect.  


Return value  
none

If Haptic already playing, restarts it. 
    
    
    -- Rumble with gun Haptic effect
    local haptic_effect
    function client.init()
    	haptic_effect = LoadHaptic("haptic/gun_fire.xml")
    end
    
    function client.tick()
    	if InputPressed("interact") then
    		PlayHapticDirectional(haptic_effect, Vec(-1, 0, 0), 1)
    	end
    end
    
    

* * *

### HapticIsPlaying CLIENT ONLY
    
    
    flag = HapticIsPlaying(handle)

Arguments  
handle (string) - Handle of haptic effect  


Return value  
flag (boolean) - is current Haptic playing or not  

    
    
    -- Rumble infinitely
    local haptic_effect
    function client.init()
    	haptic_effect = LoadHaptic("haptic/gun_fire.xml")
    end
    
    function client.tick()
    	if not HapticIsPlaying(haptic_effect) then
    		PlayHaptic(haptic_effect, 1)
    	end
    end
    
    

* * *

### SetToolHaptic CLIENT ONLY
    
    
    SetToolHaptic(id, handle, [amplitude])

Arguments  
id (string) - Tool unique identifier  
handle (string) - Handle of haptic effect  
amplitude (number, optional) - Amplitude multiplier. Default (1.0)  


Return value  
none

Register haptic as a "Tool haptic" for custom tools. "Tool haptic" will be played on repeat while this tool is active. Also it can be used for Active Triggers of DualSense controller 
    
    
    function client.init()
    	RegisterTool("minigun", "loc@MINIGUN", "MOD/vox/minigun.vox")
    	toolHaptic = LoadHaptic("MOD/haptic/tool.xml")
    	SetToolHaptic("minigun", toolHaptic)
    end
    
    

* * *

### StopHaptic CLIENT ONLY
    
    
    StopHaptic(handle)

Arguments  
handle (string) - Handle of haptic effect  


Return value  
none
    
    
    -- Rumble infinitely
    local haptic_effect
    function client.init()
    	haptic_effect = LoadHaptic("haptic/gun_fire.xml")
    end
    
    function client.tick()
        if InputDown("interact") then
            StopHaptic(haptic_effect)
        elseif not HapticIsPlaying(haptic_effect) then
    		PlayHaptic(haptic_effect, 1)
        end
    end
    
    

* * *

### AddHeat SERVER ONLY
    
    
    AddHeat(shape, pos, amount)

Arguments  
shape (number) - Shape handle  
pos (TVec) - World space point as vector  
amount (number) - amount of heat  


Return value  
none

Adds heat to shape. It works similar to blowtorch. As soon as the heat of the voxel reaches a critical value, it destroys and can ignite the surrounding voxels. 
    
    
    function server.tick(dt)
    	if InputDown("usetool") then
    		local playerCameraTransform = GetPlayerCameraTransform()
    		local dir = TransformToParentVec(playerCameraTransform, Vec(0, 0, -1))
    
    		-- Cast ray out of player camera and add heat to shape if we can find one
    		local hit, dist, normal, shape = QueryRaycast(playerCameraTransform.pos, dir, 50)
    
    		if hit then
    			local hitPos = VecAdd(playerCameraTransform.pos, VecScale(dir, dist))
    			AddHeat(shape, hitPos, 2 * dt)
    		end
    
    		DrawLine(VecAdd(playerCameraTransform.pos, Vec(0.5, 0, 0)), VecAdd(playerCameraTransform.pos, VecScale(dir, dist)), 1, 0, 0, 1)
    	end
    end
    
    

* * *

### GetBoundaryArea 
    
    
    area = GetBoundaryArea()

Arguments  
none

Return value  
area (Number) - Number representing the area of the boundary.  


Returns the area of the boundary if present, otherwise the xz-area of the world body aabb. 
    
    
    function GenerateRandomPointInLevel()
    	aabbMin, aabbMax = GetBoundaryBounds()
    	local x = GetRandomFloat(aabbMin[1], aabbMax[1])
    	local z = GetRandomFloat(aabbMin[3], aabbMax[3])
    	return x,z
    end
    
    

* * *

### GetBoundaryBounds 
    
    
    min, max = GetBoundaryBounds()

Arguments  
none

Return value  
min (Vec) - Vector representing the AABB lower bound  
max (Vec) - Vector representing the AABB upper bound  


return the aabb bounds for the boundary if present, otherwise the boundary for the world body. 
    
    
    function GenerateRandomPointInLevel()
    	aabbMin, aabbMax = GetBoundaryBounds()
    	local x = GetRandomFloat(aabbMin[1], aabbMax[1])
    	local z = GetRandomFloat(aabbMin[3], aabbMax[3])
    	return x,z
    end
    
    

* * *

### GetGravity 
    
    
    vector = GetGravity()

Arguments  
none

Return value  
vector (TVec) - Gravity vector  


Returns the gravity value on the scene. 
    
    
    function client.tick()
    	DebugPrint(VecStr(GetGravity()))
    end
    
    

* * *

### SetGravity SERVER ONLY
    
    
    SetGravity(vec)

Arguments  
vec (TVec) - Gravity vector  


Return value  
none

Sets the gravity value on the scene. When the scene restarts, it resets to the default value (0, -10, 0). 
    
    
    local isMoonGravityEnabled = false
    
    function server.tick()
    	if InputPressed("g", hostPlayerId) then
    		isMoonGravityEnabled = not isMoonGravityEnabled
    		if isMoonGravityEnabled then
    			SetGravity(Vec(0, -1.6, 0))
    		else
    			SetGravity(Vec(0, -10.0, 0))
    		end
    	end
    end
    
    

* * *

### GetFps 
    
    
    fps = GetFps()

Arguments  
none

Return value  
fps (number) - Frames per second  


Returns the fps value based on general game timestep. It doesn't depend on whether it is called from tick or update. 
    
    
    function client.tick()
    	DebugWatch("fps", GetFps())
    end
    
    

* * *

### UiMakeInteractive 
    
    
    UiMakeInteractive()

Arguments  
none

Return value  
none

Calling this function will disable game input, bring up the mouse pointer and allow Ui interaction with the calling script without pausing the game. This can be useful to make interactive user interfaces from scripts while the game is running. Call this continuously every frame as long as Ui interaction is desired. 
    
    
    UiMakeInteractive()
    
    

* * *

### UiPush 
    
    
    UiPush()

Arguments  
none

Return value  
none

Push state onto stack. This is used in combination with UiPop to remember a state and restore to that state later. 
    
    
    UiColor(1,0,0)
    UiText("Red")
    UiPush()
    	UiColor(0,1,0)
    	UiText("Green")
    UiPop()
    UiText("Red")
    
    

* * *

### UiPop 
    
    
    UiPop()

Arguments  
none

Return value  
none

Pop state from stack and make it the current one. This is used in combination with UiPush to remember a previous state and go back to it later. 
    
    
    UiColor(1,0,0)
    UiText("Red")
    UiPush()
    	UiColor(0,1,0)
    	UiText("Green")
    UiPop()
    UiText("Red")
    
    

* * *

### UiWidth 
    
    
    width = UiWidth()

Arguments  
none

Return value  
width (number) - Width of draw context  

    
    
    local w = UiWidth()
    
    

* * *

### UiHeight 
    
    
    height = UiHeight()

Arguments  
none

Return value  
height (number) - Height of draw context  

    
    
    local h = UiHeight()
    
    

* * *

### UiCenter 
    
    
    center = UiCenter()

Arguments  
none

Return value  
center (number) - Half width of draw context  

    
    
    local c = UiCenter()
    --Same as
    local c = UiWidth()/2
    
    

* * *

### UiMiddle 
    
    
    middle = UiMiddle()

Arguments  
none

Return value  
middle (number) - Half height of draw context  

    
    
    local m = UiMiddle()
    --Same as
    local m = UiHeight()/2
    
    

* * *

### UiColor 
    
    
    UiColor(r, g, b, [a])

Arguments  
r (number) - Red channel  
g (number) - Green channel  
b (number) - Blue channel  
a (number, optional) - Alpha channel. Default 1.0  


Return value  
none
    
    
    --Set color yellow
    UiColor(1,1,0)
    
    

* * *

### UiColorFilter 
    
    
    UiColorFilter(r, g, b, [a])

Arguments  
r (number) - Red channel  
g (number) - Green channel  
b (number) - Blue channel  
a (number, optional) - Alpha channel. Default 1.0  


Return value  
none

Color filter, multiplied to all future colors in this scope 
    
    
    UiPush()
    	--Draw menu in transparent, yellow color tint
    	UiColorFilter(1, 1, 0, 0.5)
    	drawMenu()
    UiPop()
    
    

* * *

### UiResetColor 
    
    
    UiResetColor()

Arguments  
none

Return value  
none

Resets the ui context's color, outline color, shadow color, color filter to default values.   
Remarkable that if some component, lets call it "parent", wants to hide everyting in it's scope,   
it is possible that a child which uses UiResetColor would ignore the hide logic, if its implemented via changing opacity. 
    
    
    function client.draw()
    	UiPush()
            UiFont("bold.ttf", 44)
    		UiTranslate(100, 100)
    		UiColor(1, 0, 0)
    		UiText("A")
    		UiTranslate(100, 0)
    		UiResetColor()
    		UiText("B")
    	UiPop()
    end
    
    

* * *

### UiTranslate 
    
    
    UiTranslate(x, y)

Arguments  
x (number) - X component  
y (number) - Y component  


Return value  
none

Translate cursor 
    
    
    UiPush()
    	UiTranslate(100, 0)
    	UiText("Indented")
    UiPop()
    
    

* * *

### UiRotate 
    
    
    UiRotate(angle)

Arguments  
angle (number) - Angle in degrees, counter clockwise  


Return value  
none

Rotate cursor 
    
    
    UiPush()
    	UiRotate(45)
    	UiText("Rotated")
    UiPop()
    
    

* * *

### UiScale 
    
    
    UiScale(x, [y])

Arguments  
x (number) - X component  
y (number, optional) - Y component. Default value is x.  


Return value  
none

Scale cursor either uniformly (one argument) or non-uniformly (two arguments) 
    
    
    UiPush()
    	UiScale(2)
    	UiText("Double size")
    UiPop()
    
    

* * *

### UiGetScale 
    
    
    x, y = UiGetScale()

Arguments  
none

Return value  
x (number) - X scale  
y (number) - Y scale  


Returns the ui context's scale 
    
    
    function client.draw()
    	UiPush()
    		UiScale(2)
    		x, y = UiGetScale()
    		DebugPrint(x .. " " .. y)
    	UiPop()
    end
    
    

* * *

### UiClipRect 
    
    
    UiClipRect(width, height, [inherit])

Arguments  
width (number) - Rect width  
height (number) - Rect height  
inherit (boolean, optional) - True if must include the parent's clip rect  


Return value  
none

Specifies the area beyond which ui is cut off and not drawn.  
If inherit is true the resulting rect clip will be equal to the overlapped area of both rects 
    
    
    function client.draw()
        UiTranslate(200, 200)
        UiPush()
            UiClipRect(100, 50)
            UiTranslate(5, 15)
            UiFont("regular.ttf", 50)
            UiText("Text")
        UiPop()
    end
    
    
    

* * *

### UiWindow 
    
    
    UiWindow(width, height, [clip], [inherit])

Arguments  
width (number) - Window width  
height (number) - Window height  
clip (boolean, optional) - Clip content outside window. Default is false.  
inherit (boolean, optional) - Inherit current clip region (for nested clip regions)  


Return value  
none

Set up new bounds. Calls to UiWidth, UiHeight, UiCenter and UiMiddle will operate in the context of the window size. If clip is set to true, contents of window will be clipped to bounds (only works properly for non-rotated windows). 
    
    
    UiPush()
    	UiWindow(400, 200)
    	local w = UiWidth()
    	--w is now 400
    UiPop()
    
    

* * *

### UiGetCurrentWindow 
    
    
    tl_x, tl_y, br_x, br_y = UiGetCurrentWindow()

Arguments  
none

Return value  
tl_x (number) - Top left x  
tl_y (number) - Top left y  
br_x (number) - Bottom right x  
br_y (number) - Bottom right y  


Returns the top left & bottom right points of the current window 
    
    
    function client.draw()
    	UiPush()
    		UiWindow(400, 200)
    		tl_x, tl_y, br_x, br_y = UiGetCurrentWindow()
    		-- do something
    	UiPop()
    end
    
    

* * *

### UiIsInCurrentWindow 
    
    
    val = UiIsInCurrentWindow(x, y)

Arguments  
x (number) - X  
y (number) - Y  


Return value  
val (boolean) - True if  


True if the specified point is within the boundaries of the current window 
    
    
    function client.draw()
    	UiPush()
    		UiWindow(400, 200)
    		DebugPrint("point 1: " .. tostring(UiIsInCurrentWindow(200, 100)))
            DebugPrint("point 2: " .. tostring(UiIsInCurrentWindow(450, 100)))
    	UiPop()
    end
    
    

* * *

### UiIsRectFullyClipped 
    
    
    value = UiIsRectFullyClipped(w, h)

Arguments  
w (number) - Width  
h (number) - Height  


Return value  
value (boolean) - True if rect is fully clipped  


Checks whether a rectangle with width w and height h is completely clipped 
    
    
    function client.draw()
        UiTranslate(200, 200)
        UiPush()
            UiClipRect(150, 150)
            UiColor(1.0, 1.0, 1.0, 0.15)
            UiRect(150, 150)
            UiRect(w, h)
            UiTranslate(-50, 30)
            UiColor(1, 0, 0)
            local w, h = 100, 100
            UiRect(w, h)
            DebugPrint(UiIsRectFullyClipped(w, h))
        UiPop()
    end
    
    

* * *

### UiIsInClipRegion 
    
    
    value = UiIsInClipRegion(x, y)

Arguments  
x (number) - X  
y (number) - Y  


Return value  
value (boolean) - True if point is in clip region  


Checks whether a point is inside the clip region 
    
    
    function client.draw()
        UiPush()
            UiTranslate(200, 200)
            UiClipRect(150, 150)
            UiColor(1.0, 1.0, 1.0, 0.15)
            UiRect(150, 150)
            UiRect(w, h)
    
            DebugPrint("point 1: " .. tostring(UiIsInClipRegion(250, 250)))
            DebugPrint("point 2: " .. tostring(UiIsInClipRegion(350, 250)))
        UiPop()
    end
    
    

* * *

### UiIsFullyClipped 
    
    
    value = UiIsFullyClipped(w, h)

Arguments  
w (number) - Width  
h (number) - Height  


Return value  
value (boolean) - True if rect is not overlapping clip region  


Checks whether a rect is overlap the clip region 
    
    
    function client.draw()
        UiPush()
            UiTranslate(200, 200)
            UiClipRect(150, 150)
            UiColor(1.0, 1.0, 1.0, 0.15)
            UiRect(150, 150)
            UiRect(w, h)
    
            DebugPrint("rect 1: " .. tostring(UiIsFullyClipped(200, 200)))
            UiTranslate(200, 0)
            DebugPrint("rect 2: " .. tostring(UiIsFullyClipped(200, 200)))
        UiPop()
    end
    
    

* * *

### UiSafeMargins 
    
    
    x0, y0, x1, y1 = UiSafeMargins()

Arguments  
none

Return value  
x0 (number) - Left  
y0 (number) - Top  
x1 (number) - Right  
y1 (number) - Bottom  


Return a safe drawing area that will always be visible regardless of display aspect ratio. The safe drawing area will always be 1920 by 1080 in size. This is useful for setting up a fixed size UI. 
    
    
    function client.draw()
    	local x0, y0, x1, y1 = UiSafeMargins()
    	UiTranslate(x0, y0)
    	UiWindow(x1-x0, y1-y0, true)
    	--The drawing area is now 1920 by 1080 in the center of screen
    	drawMenu()
    end
    
    

* * *

### UiCanvasSize 
    
    
    value = UiCanvasSize()

Arguments  
none

Return value  
value (table) - Canvas width and height  


Returns the canvas size. "Canvas" means a coordinate space in which UI is drawn 
    
    
    function client.draw()
    	UiPush()
            local canvas = UiCanvasSize()
            UiWindow(canvas.w, canvas.h)
            --[[
                ...
            ]]
    	UiPop()
    end
    
    

* * *

### UiAlign 
    
    
    UiAlign(alignment)

Arguments  
alignment (string) - Alignment keywords  


Return value  
none

The alignment determines how content is aligned with respect to the cursor.  Alignment |  Description  
---|---  
left |  Horizontally align to the left  
right |  Horizontally align to the right  
center |  Horizontally align to the center  
top |  Vertically align to the top  
bottom |  Veritcally align to the bottom  
middle |  Vertically align to the middle  
Alignment can contain combinations of these, for instance: "center middle", "left top", "center top", etc. If horizontal or vertical alginment is omitted it will depend on the element drawn. Text, for instance has default vertical alignment at baseline. 
    
    
    UiAlign("left")
    UiText("Aligned left at baseline")
    
    UiAlign("center middle")
    UiText("Fully centered")
    
    

* * *

### UiTextAlignment 
    
    
    UiTextAlignment(alignment)

Arguments  
alignment (string) - Alignment keyword  


Return value  
none

The alignment determines how text is aligned with respect to the cursor and wrap width.  Alignment |  Description  
---|---  
left |  Horizontally align to the left  
right |  Horizontally align to the right  
center |  Horizontally align to the center  
Alignment can contain either "center", "left", or "right" 
    
    
    UiTextAlignment("left")
    UiText("Aligned left at baseline")
    
    UiTextAlignment("center")
    UiText("Centered")
    
    

* * *

### UiModalBegin 
    
    
    UiModalBegin([force])

Arguments  
force (boolean, optional) - Pass true if you need to increase the priority of this modal in the context  


Return value  
none

Disable input for everything, except what's between UiModalBegin and UiModalEnd (or if modal state is popped) 
    
    
    UiModalBegin()
    if UiTextButton("Okay") then
    	--All other interactive ui elements except this one are disabled
    end
    UiModalEnd()
    
    --This is also okay
    UiPush()
    	UiModalBegin()
    	if UiTextButton("Okay") then
    		--All other interactive ui elements except this one are disabled
    	end
    UiPop()
    --No longer modal
    
    

* * *

### UiModalEnd 
    
    
    UiModalEnd()

Arguments  
none

Return value  
none

Disable input for everything, except what's between UiModalBegin and UiModalEnd Calling this function is optional. Modality is part of the current state and will be lost if modal state is popped. 
    
    
    UiModalBegin()
    if UiTextButton("Okay") then
    	--All other interactive ui elements except this one are disabled
    end
    UiModalEnd()
    
    

* * *

### UiDisableInput 
    
    
    UiDisableInput()

Arguments  
none

Return value  
none

Disable input 
    
    
    UiPush()
    	UiDisableInput()
    	if UiTextButton("Okay") then
    		--Will never happen
    	end
    UiPop()
    
    

* * *

### UiEnableInput 
    
    
    UiEnableInput()

Arguments  
none

Return value  
none

Enable input that has been previously disabled 
    
    
    UiDisableInput()
    if UiTextButton("Okay") then
    	--Will never happen
    end
    
    UiEnableInput()
    if UiTextButton("Okay") then
    	--This can happen
    end
    
    

* * *

### UiReceivesInput 
    
    
    receives = UiReceivesInput()

Arguments  
none

Return value  
receives (boolean) - True if current context receives input  


This function will check current state receives input. This is the case if input is not explicitly disabled with (with UiDisableInput) and no other state is currently modal (with UiModalBegin). Input functions and UI elements already do this check internally, but it can sometimes be useful to read the input state manually to trigger things in the UI. 
    
    
    if UiReceivesInput() then
    	highlightItemAtMousePointer()
    end
    
    

* * *

### UiGetMousePos 
    
    
    x, y = UiGetMousePos()

Arguments  
none

Return value  
x (number) - X coordinate  
y (number) - Y coordinate  


Get mouse pointer position relative to the cursor 
    
    
    local x, y = UiGetMousePos()
    
    

* * *

### UiGetCanvasMousePos 
    
    
    x, y = UiGetCanvasMousePos()

Arguments  
none

Return value  
x (number) - X coordinate  
y (number) - Y coordinate  


Returns position of mouse cursor in UI canvas space.  
The size of the canvas depends on the aspect ratio. For example, for 16:9, the maximum value will be 1920x1080, and for 16:10, it will be 1920x1200 
    
    
    function client.draw()
    	local x, y = UiGetCanvasMousePos()
    	DebugPrint("x :" .. x .. " y:" .. y)
    end
    
    

* * *

### UiIsMouseInRect 
    
    
    inside = UiIsMouseInRect(w, h)

Arguments  
w (number) - Width  
h (number) - Height  


Return value  
inside (boolean) - True if mouse pointer is within rectangle  


Check if mouse pointer is within rectangle. Note that this function respects alignment. 
    
    
    if UiIsMouseInRect(100, 100) then
    	-- mouse pointer is in rectangle
    end
    
    

* * *

### UiWorldToPixel 
    
    
    x, y, distance = UiWorldToPixel(point)

Arguments  
point (TVec) - 3D world position as vector  


Return value  
x (number) - X coordinate  
y (number) - Y coordinate  
distance (number) - Distance to point  


Convert world space position to user interface X and Y coordinate relative to the cursor. The distance is in meters and positive if in front of camera, negative otherwise. 
    
    
    local x, y, dist = UiWorldToPixel(point)
    if dist > 0 then
    UiTranslate(x, y)
    UiText("Label")
    end
    
    

* * *

### UiPixelToWorld 
    
    
    direction = UiPixelToWorld(x, y)

Arguments  
x (number) - X coordinate  
y (number) - Y coordinate  


Return value  
direction (TVec) - 3D world direction as vector  


Convert X and Y UI coordinate to a world direction, as seen from current camera. This can be used to raycast into the scene from the mouse pointer position. 
    
    
    UiMakeInteractive()
    local x, y = UiGetMousePos()
    local dir = UiPixelToWorld(x, y)
    local pos = GetCameraTransform().pos
    local hit, dist = QueryRaycast(pos, dir, 100)
    if hit then
    	DebugPrint("hit distance: " .. dist)
    end
    
    

* * *

### UiGetCursorPos 
    
    
    UiGetCursorPos()

Arguments  
none

Return value  
none

Returns the ui cursor's postion 
    
    
    function client.draw()
        UiTranslate(100, 50)
        x, y = UiGetCursorPos()
        DebugPrint("x: " .. x .. "; y: " .. y)
    end
    
    

* * *

### UiBlur 
    
    
    UiBlur(amount)

Arguments  
amount (number) - Blur amount (0.0 to 1.0)  


Return value  
none

Perform a gaussian blur on current screen content 
    
    
    UiBlur(1.0)
    drawMenu()
    
    

* * *

### UiFont 
    
    
    UiFont(path, size)

Arguments  
path (string) - Path to TTF font file  
size (number) - Font size (10 to 100)  


Return value  
none
    
    
    UiFont("bold.ttf", 24)
    UiText("Hello")
    
    

* * *

### UiFontHeight 
    
    
    size = UiFontHeight()

Arguments  
none

Return value  
size (number) - Font size  

    
    
    local h = UiFontHeight()
    
    

* * *

### UiText 
    
    
    w, h, x, y, linkId = UiText(text, [move], [maxChars])

Arguments  
text (string) - Print text at cursor location  
move (boolean, optional) - Automatically move cursor vertically. Default false.  
maxChars (number, optional) - Maximum amount of characters. Default 100000.  


Return value  
w (number) - Width of text  
h (number) - Height of text  
x (number) - End x-position of text.  
y (number) - End y-position of text.  
linkId (string) - Link id of clicked link  

    
    
    UiFont("bold.ttf", 24)
    UiText("Hello")
    
    ...
    
    --Automatically advance cursor
    UiText("First line", true)
    UiText("Second line", true)
    
    
    
    --Using links
    UiFont("bold.ttf", 26)
    UiTranslate(100,100)
    --Using virtual links
    link = "[[link;label=loc@UI_TEXT_FREE_ROAM_OPTIONS_LINK_NAME;id=options/game;color=#DDDD7FDD;underline=true]]"
    someText = "Some text with a link: " .. link .. " and some more text"
    
    w, h, x, y, linkId = UiText(someText)
    if linkId:len() ~= 0 then
    	if linkId == "options/game" then
    		DebugPrint(linkId.." link clicked")
    	elseif linkId == "options/sound" then
    		--Do something else
    	end
    end
    UiTranslate(0,50)
    
    --Using game links, id attribute is required, color is optional, same as virtual links
    link = "[[game://options;label=loc@UI_TEXT_FREE_ROAM_OPTIONS_LINK_NAME;id=game;color=#DDDD7FDD;underline=false]]"
    someText = "Some text with a link: " .. link .. " and some more text"
    w, h, x, y, linkId = UiText(someText)
    if linkId:len() ~= 0 then
    	DebugPrint(linkId.." link clicked")
    end
    UiTranslate(0,50)
    
    --Using http/s links is also possible, link will be opened in the default browser
    link = "[[http://www.example.com;label=loc@SOME_KEY;]]"
    someText = "Goto: " .. link
    UiText(someText)
    
    
    

* * *

### UiTextDisableWildcards 
    
    
    UiTextDisableWildcards(disable)

Arguments  
disable (boolean) - Enable or disable wildcard [[...]] substitution support in UiText  


Return value  
none
    
    
    
    UiFont("regular.ttf", 30)
    UiPush()
    	UiTextDisableWildcards(true)
    	-- icon won't be embedded here, text will be left as is
    	UiText("Text with embedded icon image [[menu:menu_accept;iconsize=42,42]]")
    UiPop()
    
    -- embedding works as expected
    UiText("Text with embedded icon image [[menu:menu_accept;iconsize=42,42]]")
    
    

* * *

### UiTextUniformHeight 
    
    
    UiTextUniformHeight(uniform)

Arguments  
uniform (boolean) - Enable or disable fixed line height for text rendering  


Return value  
none

This function toggles the use of a fixed line height for text rendering. When enabled (true), the line height is set to a constant value determined by the current font metrics, ensuring uniform spacing between lines of text. This mode is useful for maintaining consistent line spacing across different text elements, regardless of the specific characters displayed. When disabled (false), the line height adjusts dynamically to accommodate the tallest character in each line of text. 
    
    
    #include "script/common.lua"
    enabled = false
    group = 1
    local desc = {
        {
            {"A mod desc without descenders"},
            {"Author: Abcd"},
            {"Tags: map, spawnable"},
        },
        {
            {"A mod with descenders, like g, j, p, q, y"},
            {"Author: Ggjyq"},
            {"Tags: map, spawnable"},
        },
    }
    -- Function to draw text with or without uniform line height
    local function drawDescriptions()
        UiAlign("top")
        for _, text in ipairs(desc[group]) do
            UiTextUniformHeight(enabled)
            UiText(text[1], true)
        end
    end
    
    function client.draw()
        UiFont("regular.ttf", 22)
        UiTranslate(100, 100)
    
        UiPush()
            local r,g,b
            if enabled then
                r,g,b = 0,1,0
            else
                r,g,b = 1,0,0
            end
            UiColor(0,0,0)
            UiButtonImageBox("ui/common/box-solid-6.png", 6, 6, r,g,b)
            if UiTextButton("Uniform height "..(enabled and "enabled" or "disabled")) then
                enabled = not enabled
            end
            UiTranslate(0,35)
            if UiTextButton(">") then
                group = clamp(group + 1, 1, #desc)
            end
            UiTranslate(0,35)
            if UiTextButton("<") then
                group = clamp(group - 1, 1, #desc)
            end
        UiPop()
        UiTranslate(0,80)
        drawDescriptions()
    end
    
    
    

* * *

### UiGetTextSize 
    
    
    w, h, x, y = UiGetTextSize(text)

Arguments  
text (string) - A text string  


Return value  
w (number) - Width of text  
h (number) - Height of text  
x (number) - Offset x-component of text AABB  
y (number) - Offset y-component of text AABB  

    
    
    
    local w, h = UiGetTextSize("Some text")
    
    

* * *

### UiMeasureText 
    
    
    w, h = UiMeasureText(space, text/locale)

Arguments  
space (number) - Space between lines  
text/locale (string) - , ... A text strings  


Return value  
w (number) - Width of biggest line  
h (number) - Height of all lines combined with interval  

    
    
    
    local w, h = UiMeasureText(0, "Some text", "loc@key")
    
    

* * *

### UiGetSymbolsCount 
    
    
    count = UiGetSymbolsCount(text)

Arguments  
text (string) - Text  


Return value  
count (number) - Symbols count  


Returns the symbols count in the specified text.  
This function is intended to property count symbols in UTF 8 encoded string 
    
    
    function client.draw()
        DebugPrint(UiGetSymbolsCount("Hello world!"))
    end
    
    

* * *

### UiTextSymbolsSub 
    
    
    substring = UiTextSymbolsSub(text, from, to)

Arguments  
text (string) - Text  
from (number) - From element index  
to (number) - To element index  


Return value  
substring (string) - Substring  


Returns the substring. This function is intended to properly work with UTF8 encoded strings 
    
    
    function client.draw()
        DebugPrint(UiTextSymbolsSub("Hello world", 1, 5))
    end
    
    

* * *

### UiWordWrap 
    
    
    UiWordWrap(width)

Arguments  
width (number) - Maximum width of text  


Return value  
none
    
    
    UiWordWrap(200)
    UiText("Some really long text that will get wrapped into several lines")
    
    

* * *

### UiTextLineSpacing 
    
    
    UiTextLineSpacing(value)

Arguments  
value (number) - Text linespacing  


Return value  
none

Sets the context's linespacing value of the text which is drawn using UiText 
    
    
    function client.draw()
        UiTextLineSpacing(10)
    	UiWordWrap(200)
    	UiText("TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT")
    end
    
    

* * *

### UiTextOutline 
    
    
    UiTextOutline(r, g, b, a, [thickness])

Arguments  
r (number) - Red channel  
g (number) - Green channel  
b (number) - Blue channel  
a (number) - Alpha channel  
thickness (number, optional) - Outline thickness. Default is 0.1  


Return value  
none
    
    
    --Black outline, standard thickness
    UiTextOutline(0,0,0,1)
    UiText("Text with outline")
    
    

* * *

### UiTextShadow 
    
    
    UiTextShadow(r, g, b, a, [distance], [blur])

Arguments  
r (number) - Red channel  
g (number) - Green channel  
b (number) - Blue channel  
a (number) - Alpha channel  
distance (number, optional) - Shadow distance. Default is 1.0  
blur (number, optional) - Shadow blur. Default is 0.5  


Return value  
none
    
    
    --Black drop shadow, 50% transparent, distance 2
    UiTextShadow(0, 0, 0, 0.5, 2.0)
    UiText("Text with drop shadow")
    
    

* * *

### UiRect 
    
    
    UiRect(w, h)

Arguments  
w (number) - Width  
h (number) - Height  


Return value  
none

Draw solid rectangle at cursor position 
    
    
    --Draw full-screen black rectangle
    UiColor(0, 0, 0)
    UiRect(UiWidth(), UiHeight())
    
    --Draw smaller, red, rotating rectangle in center of screen
    UiPush()
    	UiColor(1, 0, 0)
    	UiTranslate(UiCenter(), UiMiddle())
    	UiRotate(GetTime())
    	UiAlign("center middle")
    	UiRect(100, 100)
    UiPop()
    
    

* * *

### UiRectOutline 
    
    
    UiRectOutline(width, height, thickness)

Arguments  
width (number) - Rectangle width  
height (number) - Rectangle height  
thickness (number) - Rectangle outline thickness  


Return value  
none

Draw rectangle outline at cursor position 
    
    
    --Draw a red rotating rectangle outline in center of screen
    UiPush()
    	UiColor(1, 0, 0)
    	UiTranslate(UiCenter(), UiMiddle())
    	UiRotate(GetTime())
    	UiAlign("center middle")
    	UiRectOutline(100, 100, 5)
    UiPop()
    
    

* * *

### UiRoundedRect 
    
    
    UiRoundedRect(width, height, roundingRadius)

Arguments  
width (number) - Rectangle width  
height (number) - Rectangle height  
roundingRadius (number) - Round corners radius  


Return value  
none

Draw a solid rectangle with round corners of specified radius 
    
    
    UiPush()
    	UiColor(1, 0, 0)
    	UiTranslate(UiCenter(), UiMiddle())
    	UiRotate(GetTime())
    	UiAlign("center middle")
    	UiRoundedRect(100, 100, 8)
    UiPop()
    
    

* * *

### UiRoundedRectOutline 
    
    
    UiRoundedRectOutline(width, height, roundingRadius, thickness)

Arguments  
width (number) - Rectangle width  
height (number) - Rectangle height  
roundingRadius (number) - Round corners radius  
thickness (number) - Rectangle outline thickness  


Return value  
none

Draw rectangle outline with round corners at cursor position 
    
    
    UiPush()
    	UiColor(1, 0, 0)
    	UiTranslate(UiCenter(), UiMiddle())
    	UiRotate(GetTime())
    	UiAlign("center middle")
    	UiRoundedRectOutline(100, 100, 20, 5)
    UiPop()
    
    

* * *

### UiCircle 
    
    
    UiCircle(radius)

Arguments  
radius (number) - Circle radius  


Return value  
none

Draw a solid circle at cursor position 
    
    
    UiPush()
    	UiColor(1, 0, 0)
    	UiTranslate(UiCenter(), UiMiddle())
    	UiAlign("center middle")
    	UiCircle(100)
    UiPop()
    
    

* * *

### UiCircleOutline 
    
    
    UiCircleOutline(radius, thickness)

Arguments  
radius (number) - Circle radius  
thickness (number) - Circle outline thickness  


Return value  
none

Draw a circle outline at cursor position 
    
    
    --Draw a red rotating rectangle outline in center of screen
    UiPush()
    	UiColor(1, 0, 0)
    	UiTranslate(UiCenter(), UiMiddle())
    	UiAlign("center middle")
    	UiCircleOutline(100, 8)
    UiPop()
    
    

* * *

### UiFillImage 
    
    
    UiFillImage(path)

Arguments  
path (string) - Path to image (PNG or JPG format)  


Return value  
none

Image to fill for UiRoundedRect, UiCircle 
    
    
    UiPush()
    	UiFillImage("ui/hud/tutorial/plank-lift.jpg")
    	UiTranslate(UiCenter(), UiMiddle())
    	UiRotate(GetTime())
    	UiAlign("center middle")
    	UiRoundedRect(100, 100, 8)
    UiPop()
    
    

* * *

### UiBackgroundBlur 
    
    
    UiBackgroundBlur(amount)

Arguments  
amount (number) - Blur amount (0.0 to 1.0)  


Return value  
none

Perform a gaussian blur on the background and applies the blur to any following calls to UiRect, UiRectOutline, UiRoundedRect, UiCircle, UiCircleOutline, UiRoundedRectOutline. 
    
    
    UiBackgroundBlur(1.0)
    UiRect(300, 300)
    
    

* * *

### UiImage 
    
    
    w, h = UiImage(path, [x0], [y0], [x1], [y1])

Arguments  
path (string) - Path to image (PNG or JPG format)  
x0 (number, optional) - Lower x coordinate (default is 0)  
y0 (number, optional) - Lower y coordinate (default is 0)  
x1 (number, optional) - Upper x coordinate (default is image width)  
y1 (number, optional) - Upper y coordinate (default is image height)  


Return value  
w (number) - Width of drawn image  
h (number) - Height of drawn image  


Draw image at cursor position. If x0, y0, x1, y1 is provided a cropped version will be drawn in that coordinate range. 
    
    
    --Draw image in center of screen
    UiPush()
    	UiTranslate(UiCenter(), UiMiddle())
    	UiAlign("center middle")
    	UiImage("test.png")
    UiPop()
    
    

* * *

### UiUnloadImage 
    
    
    UiUnloadImage(path)

Arguments  
path (string) - Path to image (PNG or JPG format)  


Return value  
none

Unloads a texture from the memory 
    
    
    local image = "gfx/cursor.png"
    
    function client.draw()
        UiTranslate(300, 300)
    	if UiHasImage(image) then
    		if InputDown("interact") then
    			UiUnloadImage("img/background.jpg")
    		else
    			UiImage(image)
    		end
    	end
    end
    
    

* * *

### UiHasImage 
    
    
    exists = UiHasImage(path)

Arguments  
path (string) - Path to image (PNG or JPG format)  


Return value  
exists (boolean) - Does the image exists at the specified path  

    
    
    local image = "gfx/circle.png"
    
    function client.draw()
    	if UiHasImage(image) then
    		DebugPrint("image " .. image .. " exists")
    	end
    end
    
    

* * *

### UiGetImageSize 
    
    
    w, h = UiGetImageSize(path)

Arguments  
path (string) - Path to image (PNG or JPG format)  


Return value  
w (number) - Image width  
h (number) - Image height  


Get image size 
    
    
    local w,h = UiGetImageSize("test.png")
    
    

* * *

### UiImageBox 
    
    
    UiImageBox(path, width, height, [borderWidth], [borderHeight])

Arguments  
path (string) - Path to image (PNG or JPG format)  
width (number) - Width  
height (number) - Height  
borderWidth (number, optional) - Border width. Default 0  
borderHeight (number, optional) - Border height. Default 0  


Return value  
none

Draw 9-slice image at cursor position. Width should be at least 2*borderWidth. Height should be at least 2*borderHeight. 
    
    
    UiImageBox("menu-frame.png", 200, 200, 10, 10)
    
    

* * *

### UiSound 
    
    
    UiSound(path, [volume], [pitch], [panAzimuth], [panDepth])

Arguments  
path (string) - Path to sound file (OGG format)  
volume (number, optional) - Playback volume. Default 1.0  
pitch (number, optional) - Playback pitch. Default 1.0  
panAzimuth (number, optional) - Playback stereo panning azimuth (-PI to PI). Default 0.0.  
panDepth (number, optional) - Playback stereo panning depth (0.0 to 1.0). Default 1.0.  


Return value  
none

UI sounds are not affected by acoustics simulation. Use LoadSound / PlaySound for that. 
    
    
    UiSound("click.ogg")
    
    

* * *

### UiSoundLoop 
    
    
    UiSoundLoop(path, [volume], [pitch])

Arguments  
path (string) - Path to looping sound file (OGG format)  
volume (number, optional) - Playback volume. Default 1.0  
pitch (number, optional) - Playback pitch. Default 1.0  


Return value  
none

Call this continuously to keep playing loop. UI sounds are not affected by acoustics simulation. Use LoadLoop / PlayLoop for that. 
    
    
    if animating then
    	UiSoundLoop("screech.ogg")
    end
    
    

* * *

### UiMute 
    
    
    UiMute(amount, [music])

Arguments  
amount (number) - Mute by this amount (0.0 to 1.0)  
music (boolean, optional) - Mute music as well  


Return value  
none

Mute game audio and optionally music for the next frame. Call continuously to stay muted. 
    
    
    if menuOpen then
    	UiMute(1.0)
    end
    
    

* * *

### UiButtonImageBox 
    
    
    UiButtonImageBox(path, borderWidth, borderHeight, [r], [g], [b], [a])

Arguments  
path (string) - Path to image (PNG or JPG format)  
borderWidth (number) - Border width  
borderHeight (number) - Border height  
r (number, optional) - Red multiply. Default 1.0  
g (number, optional) - Green multiply. Default 1.0  
b (number, optional) - Blue multiply. Default 1.0  
a (number, optional) - Alpha channel. Default 1.0  


Return value  
none

Set up 9-slice image to be used as background for buttons. 
    
    
    UiButtonImageBox("button-9slice.png", 10, 10)
    if UiTextButton("Test") then
    	...
    end
    
    

* * *

### UiButtonHoverColor 
    
    
    UiButtonHoverColor(r, g, b, [a])

Arguments  
r (number) - Red multiply  
g (number) - Green multiply  
b (number) - Blue multiply  
a (number, optional) - Alpha channel. Default 1.0  


Return value  
none

Button color filter when hovering mouse pointer. 
    
    
    UiButtonHoverColor(1, 0, 0)
    if UiTextButton("Test") then
    	...
    end
    
    

* * *

### UiButtonPressColor 
    
    
    UiButtonPressColor(r, g, b, [a])

Arguments  
r (number) - Red multiply  
g (number) - Green multiply  
b (number) - Blue multiply  
a (number, optional) - Alpha channel. Default 1.0  


Return value  
none

Button color filter when pressing down. 
    
    
    UiButtonPressColor(0, 1, 0)
    if UiTextButton("Test") then
    	...
    end
    
    

* * *

### UiButtonPressDist 
    
    
    UiButtonPressDist(distX, distY)

Arguments  
distX (number) - Press distance along X axis  
distY (number) - Press distance along Y axis  


Return value  
none

The button offset when being pressed 
    
    
    UiButtonPressDistance(4, 4)
    if UiTextButton("Test") then
    	...
    end
    
    

* * *

### UiButtonTextHandling 
    
    
    UiButtonTextHandling(type)

Arguments  
type (number) - One of the enum value  


Return value  
none

indicating how to handle text overflow. Possible values are: 0 - AsIs, 1 - Slide, 2 - Truncate, 3 - Fade, 4 - Resize (Default) 
    
    
    UiButtonTextHandling(1)
    if UiTextButton("Test") then
    	...
    end
    
    

* * *

### UiTextButton 
    
    
    pressed = UiTextButton(text, [w], [h])

Arguments  
text (string) - Text on button  
w (number, optional) - Button width  
h (number, optional) - Button height  


Return value  
pressed (boolean) - True if user clicked button  

    
    
    if UiTextButton("Test") then
    	...
    end
    
    

* * *

### UiImageButton 
    
    
    pressed = UiImageButton(path)

Arguments  
path (string) - Image path (PNG or JPG file)  


Return value  
pressed (boolean) - True if user clicked button  

    
    
    if UiImageButton("image.png") then
    	...
    end
    
    

* * *

### UiBlankButton 
    
    
    pressed = UiBlankButton(w, h)

Arguments  
w (number) - Button width  
h (number) - Button height  


Return value  
pressed (boolean) - True if user clicked button  

    
    
    if UiBlankButton(30, 30) then
    	...
    end
    
    

* * *

### UiSlider 
    
    
    value, done = UiSlider(path, axis, current, min, max)

Arguments  
path (string) - Image path (PNG or JPG file)  
axis (string) - Drag axis, must be "x" or "y"  
current (number) - Current value  
min (number) - Minimum value  
max (number) - Maximum value  


Return value  
value (number) - New value, same as current if not changed  
done (boolean) - True if user is finished changing (released slider)  

    
    
    value = UiSlider("dot.png", "x", value, 0, 100)
    
    

* * *

### UiSliderHoverColorFilter 
    
    
    UiSliderHoverColorFilter(r, g, b, a)

Arguments  
r (number) - Red channel  
g (number) - Green channel  
b (number) - Blue channel  
a (number) - Alpha channel  


Return value  
none

Sets the slider hover color filter 
    
    
    local slider = 0
    
    function client.draw()
        local thumbPath = "common/thumb_I218_249_2430_49029.png"
        UiTranslate(200, 200)
        UiPush()
            UiMakeInteractive()
            UiPush()
                UiAlign("top right")
                UiTranslate(40, 3.4)
                UiColor(0.5291666388511658, 0.5291666388511658, 0.5291666388511658, 1)
                UiFont("regular.ttf", 27)
                UiText("slider")
            UiPop()
            UiTranslate(45.0, 3.0)
            UiPush()
                UiTranslate(0, 4.0)
                UiImageBox("common/rect_c#ffffff_o0.10_cr3.png", 301.0, 12.0, 4, 4)
            UiPop()
            UiTranslate(2, 0)
            UiSliderHoverColorFilter(1.0, 0.2, 0.2)
            UiSliderThumbSize(8, 20)
            slider = UiSlider(thumbPath, "x", slider * 295, 0, 295) / 295
        UiPop()
    end
    
    

* * *

### UiSliderThumbSize 
    
    
    UiSliderThumbSize(width, height)

Arguments  
width (number) - Thumb width  
height (number) - Thumb height  


Return value  
none

Sets the slider thumb size 
    
    
    local slider = 0
    
    function client.draw()
        local thumbPath = "common/thumb_I218_249_2430_49029.png"
        UiTranslate(200, 200)
        UiPush()
            UiMakeInteractive()
            UiPush()
                UiAlign("top right")
                UiTranslate(40, 3.4)
                UiColor(0.5291666388511658, 0.5291666388511658, 0.5291666388511658, 1)
                UiFont("regular.ttf", 27)
                UiText("slider")
            UiPop()
            UiTranslate(45.0, 3.0)
            UiPush()
                UiTranslate(0, 4.0)
                UiImageBox("common/rect_c#ffffff_o0.10_cr3.png", 301.0, 12.0, 4, 4)
            UiPop()
            UiTranslate(2, 0)
            UiSliderHoverColorFilter(1.0, 0.2, 0.2)
            UiSliderThumbSize(8, 20)
            slider = UiSlider(thumbPath, "x", slider * 295, 0, 295) / 295
        UiPop()
    end
    
    

* * *

### UiGetScreen 
    
    
    handle = UiGetScreen()

Arguments  
none

Return value  
handle (number) - Handle to the screen running this script or zero if none.  

    
    
    --Turn off screen running current script
    screen = UiGetScreen()
    SetScreenEnabled(screen, false)
    
    

* * *

### UiNavComponent 
    
    
    id = UiNavComponent(w, h)

Arguments  
w (number) - Width of the component  
h (number) - Height of the component  


Return value  
id (string) - Generated ID of the component which can be used to get an info about the component state  


Declares a navigation component which participates in navigation using dpad buttons of a gamepad. It's an abstract entity which can be focused. It has it's own size and position on screen according to UI cursor and passed arguments, but it won't be drawn on the screen. Note that all navigation components which are located outside of UiWindow borders won't participate in the navigation and will be considered as inactive 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
    		-- active mouse cursor has higher priority over the gamepad control
    		-- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
        UiTranslate(960, 540)
        local id = UiNavComponent(100, 20)
        local isInFocus = UiIsComponentInFocus(id)
        if isInFocus then
            local rect = UiFocusedComponentRect()
            DebugPrint("Position: (" .. tostring(rect.x) .. ", " .. tostring(rect.y) .. "), Size: (" .. tostring(rect.w) .. ", " .. tostring(rect.h) .. ")")
        end
    end
    
    

* * *

### UiIgnoreNavigation 
    
    
    UiIgnoreNavigation([ignore])

Arguments  
ignore (boolean, optional) - Whether ignore the navigation in a current UI scope or not.  


Return value  
none

Sets a flag to ingore the navgation in a current UI scope or not. By default, if argument isn't specified, the function sets the flag to true. If ignore is set to true, all components after the function call won't participate in navigation as if they didn't exist on a scene. Flag resets back to false after leaving the UI scope in which the function was called. 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
    		-- active mouse cursor has higher priority over the gamepad control
    		-- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
        UiTranslate(960, 540)
        UiNavComponent(100, 20)
    
    	UiTranslate(150, 40)
    	UiPush()
    		UiIgnoreNavigation(true)
    		local id = UiNavComponent(100, 20)
    		local isInFocus = UiIsComponentInFocus(id)
    		-- will be always "false"
    		DebugPrint(isInFocus)
    	UiPop()
    end
    
    

* * *

### UiResetNavigation 
    
    
    UiResetNavigation()

Arguments  
none

Return value  
none

Resets navigation state as if none componets before the function call were declared 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
    		-- active mouse cursor has higher priority over the gamepad control
    		-- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
        UiTranslate(960, 540)
        local id = UiNavComponent(100, 20)
    
    	UiResetNavigation()
    	UiTranslate(150, 40)
    	UiNavComponent(100, 20)
    
    	local isInFocus = UiIsComponentInFocus(id)
    	-- will be always "false"
    	DebugPrint(isInFocus)
    end
    
    

* * *

### UiNavSkipUpdate 
    
    
    UiNavSkipUpdate()

Arguments  
none

Return value  
none

Skip update of the whole navigation state in a current draw. Could be used to override behaviour of navigation in some cases. See an example. 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
    		-- active mouse cursor has higher priority over the gamepad control
    		-- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
        UiTranslate(960, 540)
    	UiNavComponent(100, 20)
    
    	UiTranslate(0, 50)
        local id = UiNavComponent(100, 20)
    	local isInFocus = UiIsComponentInFocus(id)
    
    	if isInFocus and InputPressed("menu_up") then
    		-- don't let navigation to update and if component in focus
    		-- and do different action
    		UiNavSkipUpdate()
    		DebugPrint("Navigation action UP is overrided")
    	end
    end
    
    

* * *

### UiIsComponentInFocus 
    
    
    focus = UiIsComponentInFocus(id)

Arguments  
id (string) - Navigation id of the component  


Return value  
focus (boolean) - Flag whether the component in focus on not  


Returns the flag whether the component with specified id is in focus or not 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
    		-- active mouse cursor has higher priority over the gamepad control
    		-- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
    
        UiTranslate(960, 540)
    
    	local gId = UiNavGroupBegin()
    
    	UiNavComponent(100, 20)
    	UiTranslate(0, 50)
        local id = UiNavComponent(100, 20)
    	local isInFocus = UiIsComponentInFocus(id)
    
    	UiNavGroupEnd()
    
    	local groupInFocus = UiIsComponentInFocus(gId)
    
    
    	if isInFocus then
    		DebugPrint(groupInFocus)
    	end
    end
    
    

* * *

### UiNavGroupBegin 
    
    
    id = UiNavGroupBegin([id])

Arguments  
id (string, optional) - Name of navigation group. If not presented, will be generated automatically.  


Return value  
id (string) - Generated ID of the group which can be used to get an info about the group state  


Begins a scope of a new navigation group. Navigation group is an entity which aggregates all navigation components which was declared in it's scope. The group becomes a parent entity for all aggregated components including inner group declarations. During the navigation update process the game engine first checks the focused componet for proximity to components in the same group, and then if none neighbour was found the engine starts to search for the closest group and the closest component inside that group. Navigation group has the same properties as navigation component, that is id, width and height. Group size depends on its children common bounding box or it can be set explicitly. Group is considered in focus if any of its child is in focus. 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
    		-- active mouse cursor has higher priority over the gamepad control
    		-- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
    
        UiTranslate(960, 540)
    
    	local gId = UiNavGroupBegin()
    
    	UiNavComponent(100, 20)
    	UiTranslate(0, 50)
        local id = UiNavComponent(100, 20)
    	local isInFocus = UiIsComponentInFocus(id)
    
    	UiNavGroupEnd()
    
    	local groupInFocus = UiIsComponentInFocus(gId)
    
    
    	if isInFocus then
    		DebugPrint(groupInFocus)
    	end
    end
    
    

* * *

### UiNavGroupEnd 
    
    
    UiNavGroupEnd()

Arguments  
none

Return value  
none

Ends a scope of a new navigation group. All components before that call become children of that navigation group. 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
    		-- active mouse cursor has higher priority over the gamepad control
    		-- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
    
        UiTranslate(960, 540)
    
    	local gId = UiNavGroupBegin()
    
    	UiNavComponent(100, 20)
    	UiTranslate(0, 50)
        local id = UiNavComponent(100, 20)
    	local isInFocus = UiIsComponentInFocus(id)
    
    	UiNavGroupEnd()
    
    	local groupInFocus = UiIsComponentInFocus(gId)
    
    
    	if isInFocus then
    		DebugPrint(groupInFocus)
    	end
    end
    
    

* * *

### UiNavGroupSize 
    
    
    UiNavGroupSize(w, h)

Arguments  
w (number) - Width of the component  
h (number) - Height of the component  


Return value  
none

Set a size of current navigation group explicitly. Can be used in cases when it's needed to limit area occupied by the group or make it bigger than total occupied area by children in order to catch focus from near neighbours. 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
    		-- active mouse cursor has higher priority over the gamepad control
    		-- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
    
    	UiTranslate(960, 540)
    
    	local gId = UiNavGroupBegin()
    	UiNavGroupSize(500, 300)
    
    	UiNavComponent(100, 20)
    	UiTranslate(0, 50)
        local id = UiNavComponent(100, 20)
    	local isInFocus = UiIsComponentInFocus(id)
    
    	UiNavGroupEnd()
    
    	local groupInFocus = UiIsComponentInFocus(gId)
    
        if groupInFocus then
    		-- get a rect of the focused component parent
            local rect = UiFocusedComponentRect(1)
            DebugPrint("Position: (" .. tostring(rect.x) .. ", " .. tostring(rect.y) .. "), Size: (" .. tostring(rect.w) .. ", " .. tostring(rect.h) .. ")")
        end
    end
    
    

* * *

### UiForceFocus 
    
    
    UiForceFocus(id)

Arguments  
id (string) - Id of the component  


Return value  
none

Force focus to the component with specified id. 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
            -- active mouse cursor has higher priority over the gamepad control
            -- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
    
    	UiPush()
    
        UiTranslate(960, 540)
    
        local id1 = UiNavComponent(100, 20)
        UiTranslate(0, 50)
        local id2 = UiNavComponent(100, 20)
    
    	UiPop()
    
        local f1 = UiIsComponentInFocus(id1)
        local f2 = UiIsComponentInFocus(id2)
    
        local rect = UiFocusedComponentRect()
        UiPush()
            UiColor(1, 0, 0)
            UiTranslate(rect.x, rect.y)
            UiRect(rect.w, rect.h)
        UiPop()
    
        if InputPressed("menu_accept") then
            UiForceFocus(id2)
        end
    end
    
    

* * *

### UiFocusedComponentId 
    
    
    id = UiFocusedComponentId()

Arguments  
none

Return value  
id (string) - Id of the focused component  


Returns an id of the currently focused component 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
            -- active mouse cursor has higher priority over the gamepad control
            -- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
    
    	UiPush()
    
        UiTranslate(960, 540)
    
        local id1 = UiNavComponent(100, 20)
        UiTranslate(0, 50)
        local id2 = UiNavComponent(100, 20)
    
    	UiPop()
    
        local f1 = UiIsComponentInFocus(id1)
        local f2 = UiIsComponentInFocus(id2)
    
        local rect = UiFocusedComponentRect()
        UiPush()
            UiColor(1, 0, 0)
            UiTranslate(rect.x, rect.y)
            UiRect(rect.w, rect.h)
        UiPop()
    
        DebugPrint(UiFocusedComponentId())
    end
    
    

* * *

### UiFocusedComponentRect 
    
    
    rect = UiFocusedComponentRect([n])

Arguments  
n (number, optional) - Take n-th parent of the focused component insetad of the component itself  


Return value  
rect (table) - Rect object with info about the component bounding rectangle  


Returns a bounding rect of the currently focused component. If the arg "n" is specified the function return a rect of the n-th parent group of the component. The rect contains the following fields: w - width of the component h - height of the component x - x position of the component on the canvas y - y position of the component on the canvas 
    
    
    function client.draw()
        -- window declaration is necessary for navigation to work
        UiWindow(1920, 1080)
        if LastInputDevice() == UI_DEVICE_GAMEPAD then
            -- active mouse cursor has higher priority over the gamepad control
            -- so it will reset focused components if the mouse moves
            UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
        end
    
        UiPush()
    
        UiTranslate(960, 540)
    
        local id1 = UiNavComponent(100, 20)
        UiTranslate(0, 50)
        local id2 = UiNavComponent(100, 20)
    
        UiPop()
    
        local f1 = UiIsComponentInFocus(id1)
        local f2 = UiIsComponentInFocus(id2)
    
        local rect = UiFocusedComponentRect()
        UiPush()
            UiColor(1, 0, 0)
            UiTranslate(rect.x, rect.y)
            UiRect(rect.w, rect.h)
        UiPop()
    end
    
    

* * *

### UiGetItemSize 
    
    
    x, y = UiGetItemSize()

Arguments  
none

Return value  
x (number) - Width  
y (number) - Height  


Returns the last ui item size 
    
    
    function client.draw()
        UiTranslate(200, 200)
        UiPush()
            UiBeginFrame()
                UiFont("regular.ttf", 30)
                UiText("Text")
            UiEndFrame()
            w, h = UiGetItemSize()
            DebugPrint(w .. " " .. h)
        UiPop()
    end
    
    

* * *

### UiAutoTranslate 
    
    
    UiAutoTranslate(value)

Arguments  
value (boolean) -   


Return value  
none

Enables/disables auto autotranslate function when measuring the item size 
    
    
    function client.draw()
        UiPush()
            UiBeginFrame()
                if InputDown("interact") then
                    UiAutoTranslate(false)
                else
                    UiAutoTranslate(true)
                end
    
                UiRect(50, 50)
                local w, h = UiGetItemSize()
                DebugPrint(math.ceil(w) .. "x" .. math.ceil(h))
            UiEndFrame()
        UiPop()
    end
    
    

* * *

### UiBeginFrame 
    
    
    UiBeginFrame()

Arguments  
none

Return value  
none

Call to start measuring the content size. After drawing part of the interface, call UiEndFrame to get its size. Useful when you want the size of the image box to match the size of the content. 
    
    
    function client.draw()
    	UiPush()
            UiBeginFrame()
                UiColor(1.0, 1.0, 0.8)
                UiTranslate(UiCenter(), 300)
                UiFont("bold.ttf", 40)
                UiText("Hello")
            local panelWidth, panelHeight = UiEndFrame()
            DebugPrint(math.ceil(panelWidth) .. "x" .. math.ceil(panelHeight))
        UiPop()
    end
    
    

* * *

### UiResetFrame 
    
    
    UiResetFrame()

Arguments  
none

Return value  
none

Resets the current frame measured values 
    
    
    function client.draw()
        UiPush()
            UiTranslate(UiCenter(), 300)
            UiFont("bold.ttf", 40)
            UiBeginFrame()
                UiTextButton("Button1")
                UiTranslate(200, 0)
                UiTextButton("Button2")
            UiResetFrame()
            local panelWidth, panelHeight = UiEndFrame()
            DebugPrint("w: " .. panelWidth .. "; h:" .. panelHeight)
        UiPop()
    end
    
    

* * *

### UiFrameOccupy 
    
    
    UiFrameOccupy(width, height)

Arguments  
width (number) - Width  
height (number) - Height  


Return value  
none

Occupies some space for current frame (between UiBeginFrame and UiEndFrame) 
    
    
    function client.draw()
    	UiPush()
            UiBeginFrame()
                UiColor(1.0, 1.0, 0.8)
                UiRect(200, 200)
                UiRect(300, 200)
                UiFrameOccupy(500, 500)
            local panelWidth, panelHeight = UiEndFrame()
            DebugPrint(math.ceil(panelWidth) .. "x" .. math.ceil(panelHeight))
        UiPop()
    end
    
    

* * *

### UiEndFrame 
    
    
    width, height = UiEndFrame()

Arguments  
none

Return value  
width (number) - Width of content drawn between since UiBeginFrame was called  
height (number) - Height of content drawn between since UiBeginFrame was called  

    
    
    function client.draw()
    	UiPush()
            UiBeginFrame()
                UiColor(1.0, 1.0, 0.8)
                UiRect(200, 200)
                UiRect(300, 200)
            local panelWidth, panelHeight = UiEndFrame()
            DebugPrint(math.ceil(panelWidth) .. "x" .. math.ceil(panelHeight))
        UiPop()
    end
    
    

* * *

### UiFrameSkipItem 
    
    
    UiFrameSkipItem(skip)

Arguments  
skip (boolean) - Should skip item  


Return value  
none

Sets whether to skip items in current ui scope for current ui frame. This items won't affect on the frame size 
    
    
    function client.draw()
    	UiPush()
    		UiBeginFrame()
    			UiFrameSkipItem(true)
    			--[[
    				...
    			]]
    		UiEndFrame()
    	UiPop()
    end
    
    

* * *

### UiGetFrameNo 
    
    
    frameNo = UiGetFrameNo()

Arguments  
none

Return value  
frameNo (number) - Frame number since the level start  

    
    
    function client.draw()
    	local fNo = GetFrame()
    	DebugPrint(fNo)
    end
    
    

* * *

### UiGetLanguage 
    
    
    index = UiGetLanguage()

Arguments  
none

Return value  
index (number) - Language index  

    
    
    local n = UiGetLanguage()
    
    

* * *

### UiSetCursorState 
    
    
    UiSetCursorState(state)

Arguments  
state (number) -   


Return value  
none

Possible values are:   
0 - show cursor (UI_CURSOR_SHOW)   
1 - hide cursor (UI_CURSOR_HIDE)   
2 - hide & lock cursor (UI_CURSOR_HIDE_AND_LOCK)  
  
Allows you to force visibilty of cursor for next frame. If the cursor is hidden, gamepad navigation methods are used.  
By default, in case of entering interactive UI state with gamepad, cursor will be shown and will be controlled using gamepad.  
Thus, if you need to implement navigation using the gamepad's D-pad, you should call this function. 
    
    
    #include "ui/ui_helpers.lua"
    
    function client.draw()
    	UiPush()
    		-- If the last input device was a gamepad, hide the cursor and proceed to control through D-pad navigation
    		if LastInputDevice() == UI_DEVICE_GAMEPAD then
    			UiSetCursorState(UI_CURSOR_HIDE_AND_LOCK)
    		end
    
            UiMakeInteractive()
            UiAlign("center")
            UiColor(1.0, 1.0, 1.0)
    		UiButtonHoverColor(1.0, 0.5, 0.5)
            UiFont("regular.ttf", 50)
            UiTranslate(UiCenter(), 200)
    
            UiTranslate(0, 100)
            if UiTextButton("1") then
                DebugPrint(1)
            end
            UiTranslate(0, 100)
            if UiTextButton("2") then
                DebugPrint(2)
            end
    	UiPop()
    end
    
    

* * *
