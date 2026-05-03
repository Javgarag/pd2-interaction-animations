## Docs
There are two types of supported animations:

* "Long" interactions: these consist of three animations: one for entering the interaction, one for looping during it, and a final one to exit it. This structure accounts for early cancels and AI speed boosts.
* "Instant" interactions: these are a single animation that play on the left arm, while playing another animation on the weapon arm (so that the gun is raised or out of the way). Sprinting, meleeing or shooting cancel them.

**You can also use any unit in your animation, and spawn it later**. Animations for deploying equipment are not currently supported, but can be added in a later version of the base mod.

After you've created your animation, it's time to make it available. Revise the following:
*Inside all of the template files, you have every structure you'll need; use common sense to remove anything you don't need for your animation(s). *

* Change the mod name in `mod.txt` and `main.xml`, and add any additional information (contact, author, etc).
* Inside `main.xml`, add the paths to your animations.
	* If your animation makes use of an unit (e.g. a keycard), add those paths too. **However, you need to derive a material config from the unit's original one that uses templates that include `DEPTH_SCALING` for its materials, so it is properly drawn in the game. See the MWS wiki on this file format for more info.**
* Decide on a name for the animation, it needs to be unique enough so it doesn't get used by anything else. Use it consistently inside the following files.
* Inside `scriptdata/animation_states.xml`, in *SECTION #1*, add that name to the `name` value and change the `redirect` value to include that same name at the end. Now, depending on your animation, proceed differently:
	1. If your animation **IS INSTANT**, remove sections *#2, #3, #4, and #5*. In *SECTION #6*, change the redirect to `fps/offhand/interact/{ANIMATION_NAME}` and the animation name to yours.
	2. If your animation **IS OF SEPARATE PARTS**, remove *SECTION #6*. For the rest of the sections:
		* Change the state names so that the last section is your animation name. E.g. `fps/{INTERACT_PART}/{ANIMATION_NAME}`
		* Add your animation name in the `name` attribute, with suffixes `_enter, _hold, _exit` depending on the section; for *SECTION #5*, use `_exit`.
		* In *SECTION #2*, add the name of your `interact_hold` state to the `exit` node's `name` value.  
		* In *SECTION #3*, add the names of your `interact_exit` and `interact_interupt` states to the `to` node's `redirect` value.
* Inside `scriptdata/animation_subset.xml`, point the names you added before to the `anim` nodes (so your animation name, with/without suffixes) to their corresponding files; you should have three for long interactions, and one for instantaneous ones.
* Inside `interaction_animation_tweak_data.lua`, follow the commented instructions.