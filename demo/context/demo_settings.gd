class_name DemoSettings
extends RefCounted
## Shared state the root context hands to the screens that need it.

enum Difficulty { EASY, NORMAL, HARD }

var music_on := true
var sound_on := true
var difficulty := Difficulty.NORMAL
