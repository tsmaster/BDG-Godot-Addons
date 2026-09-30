From Hovering Skull on YouTube

Context has following API  
Func build() \-\> void  
  \# builds services or other variables needed in this context

Func bind\_dependencies() \-\> void  
  \# pass in and bind any dependencies that this context needs from parent

Func setup() \-\> void  
  \# all dependencies are resolved, so do any setup necessary

Func tear\_down() \-\> void  
  \# DWL my own destructor, paired with setup, might do queue\_free?  
  \# might call it unmount?

HoveringSkull likes to have a “mount\_main\_menu()” function within the root\_context that does the FSM change state pattern:

- removing existing sub-context  
- Instantiating main menu context  
- Checking if main menu context was instantiated \- err and exit if not  
- Build main menu  
- Bind\_dependencies main menu  
- Setup main menu

