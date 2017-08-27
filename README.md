# SafeShift
Vanilla WoW addon for druids that improves shapeshifting functionality.

## Installation
Extract into your "World of Warcraft/Interface/Addons" folder. If downloaded directly, rename "SafeShift-master" to "SafeShift".

## Features
* Switch between forms without manually unshifting (example: while in bear form, spam travel form key to shift to travel form).
* Configurable safety period during which you can't unshift. This prevents accidentally unshifting while mashing a shapeshift key.

## Usage
* /safeshift - lists commands and shows current safety setting.
* /safeshift [cat | bear | direbear | travel | moonkin | aquatic] - safely shift into form without unshifting for the set period.
* /safeshift [cd | cooldown] <value in seconds> - sets the safe period during which you may not unshift. Default: 0.5 seconds.