# DSPico QuickReturn compatibility

[Project home](../README.md) · [Build 139 download and installation](https://github.com/VideoGameMore/pico-loader/releases/tag/build-137) · [LNH-team original Pico Loader](https://github.com/LNH-team/pico-loader)

## Build 139 baseline — October 8, 2026

Rich / VideoGameMore tested Build 139 against the complete 360-title list on **Nintendo DS Lite hardware with DSPico**. The procedure was **launch a game → request return with L + R + Down + Select → launch again**. This checks the return/relaunch cycle, not complete gameplay, save integrity, every menu or every ROM revision. Other console models, DSi modes and other flashcards have not been validated by this run.

| Result | Titles |
| --- | ---: |
| Pass | 298 |
| Pass with delayed return (Yoshi Touch & Go) | 1 |
| Boots, but no hotkey response | 54 |
| Partial return (Contact and Animal Crossing) | 2 |
| Boot failure (Pokémon Dash) | 1 |
| Unable to test without accessory | 4 |
| **Total** | **360** |

**299 passed, 57 had issues, and 4 were unable to test.** These are observed results for this setup, not a compatibility guarantee or a diagnosis of the cause. A boot failure has not been isolated against the original loader.

### How the results were recorded

The tester worked through the list alphabetically, reported exceptions, and confirmed the run was complete. Unreported entries are recorded as **passes inferred from that completed run**, rather than individual written confirmations. A game name alone meant it boots normally, the hotkey does nothing, and the game remains responsive. Early reports explicitly described the same behavior at menu and gameplay; exact press locations were not individually logged for every later title.

The names and USA region labels below come from the supplied test manifest. Filenames are not verification of cartridge region or ROM revision; checksums and game IDs were not recorded. “Bejeweled” resolves to **Bejeweled Twist**, and “Ōkamiden” to the manifest entry **Ookami Den**. Animal Crossing appears as **Welcome to Animal Crossing - Wild World** in that manifest. No game files are included here.

### Special observations

- **Contact:** no exit during gameplay; return was reported after running a game. The exact successful transition was not specified, so it remains a partial result pending clarification.
- **Animal Crossing: Wild World:** returns to Pico, but the game list is empty. This is a menu/storage usability failure, not a successful return/relaunch cycle.
- **Pokémon Dash:** white screens at boot; return could not be evaluated.
- **Yoshi Touch & Go:** return works during gameplay. A request before gameplay takes effect when gameplay starts.
- **Mega Man ZX:** the baseline run lists a pass; earlier development tests needed a transition into gameplay.
- **Guitar Hero: On Tour, Decades and Modern Hits:** unable to test without the Guitar Grip accessory.
- **Tony Hawk’s Motion:** unable to test without its motion accessory; the hotkey also did not reset from the accessible screen.

The Build 139 retest was confirmed by the tester to reproduce the recorded results. The branded launcher splash also worked on boot and after game return.

## Fixes and retests

Keep the Build 139 column as the historical baseline. When a later build fixes a title, fill **Fixed in** only after a hardware retest and add the dated test result below, including the build, console, region/revision if known, menu/gameplay timing and relaunch result. A code change alone is not a confirmed compatibility fix. Link the later release or patch notes here. No later fixes have been confirmed yet.

| Retest date | Game | Build | Hardware | Observation | Release / patch |
| --- | --- | --- | --- | --- | --- |
| — | No later retests recorded | — | — | — | — |

## Full compatibility table

“—” in **Fixed in** means no later fix has been verified. Pass rows use the completed-run evidence described above; exception rows use explicit tester reports.

| Game (manifest name) | Build 139 | Observation | Fixed in |
| --- | --- | --- | --- |
| Advance Wars - Dual Strike | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Advance Wars Days of Ruin | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Age of Empires - Mythologies | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Age of Empires - The Age of Kings | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Aliens - Infestation | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Amazing Spider-Man, The | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Anno 1701 - Dawn of Discovery | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Apollo Justice - Ace Attorney | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Arkanoid DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Asphalt - Urban GT | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Asphalt - Urban GT 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Assassin's Creed II - Discovery | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Assassins Creed Altairs Chronicles | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Astro Boy - The Video Game | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Avalon Code | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Bangai-O Spirits | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Batman The Brave and the Bold | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Battles of Prince of Persia | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Bejeweled Twist | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Big Bang Mini | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Black Sigil - Blade of the Exiled | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Bleach - Dark Souls | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Blue Dragon - Awakened Shadow | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Blue Dragon Plus | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Bomberman | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Bomberman Land Touch 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Bomberman Land Touch! | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Brain Age - Train Your Brain In Minutes A Day! | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Brain Age 2 - More Training in Minutes a Day | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Broken Sword - Shadow of the Templars - The Director's Cut | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Burnout Legends | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Bust-A-Move DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| C.O.P. - The Recruit | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Call of Duty - Modern Warfare - Mobilized | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Call of Duty - World at War | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Call of Duty 4 - Modern Warfare | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Call of Duty Black Ops | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Castlevania - Dawn of Sorrow | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Castlevania - Order of Ecclesia | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Castlevania - Portrait Of Ruin | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Chibi-Robo! - Park Patrol | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Chrono Trigger | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Club House Games | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Contact | Partial | No return during gameplay; return reported after running a game. Exact successful transition needs clarification. | — |
| Contra 4 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Cooking Mama | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Cooking Mama 2 - Dinner With Friends | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Cooking Mama 3 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Crash - Mind Over Mutant | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Crash Boom Bang! | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Crash Of The Titans | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Custom Robo Arena | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dawn of Discovery | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dementium - The Ward | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dementium II | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| DiRT 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Diddy Kong Racing DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Disgaea DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dokapon Journey | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Ball - Origins | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Ball - Origins 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Ball Z - Attack of the Saiyans | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Ball Z - Harukanaru Densetsu | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Ball Z - Supersonic Warriors 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Quest Heroes - Rocket Slime | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Quest IV - Chapters of the Chosen | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Quest IX - Sentinels of the Starry Skies | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Quest Monsters - Joker | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Quest Monsters - Joker 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Quest V - Hand of the Heavenly Bride | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Dragon Quest VI - Realms of Revelation | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Drawn to Life | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Drawn to Life - SpongeBob SquarePants Edition | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Drawn to Life - The Next Chapter | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Drawn to Life Collection | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Dungeon Explorer - Warrior of the Ancient Arts | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Elebits - The Adventures of Kai and Zero | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Elite Beat Agents | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Etrian Odyssey | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Etrian Odyssey II - Heroes of Lagaard | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Etrian Odyssey III - The Drowned City | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Exit DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Fighting Fantasy - The Warlock of Firetop Mountain | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Final Fantasy - The 4 Heroes of Light | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Final Fantasy Crystal Chronicles - Echoes of Time | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Final Fantasy Crystal Chronicles - Ring of Fates | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Final Fantasy Fables - Chocobo Tales | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Final Fantasy III | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Final Fantasy IV | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Final Fantasy Tactics A2 - Grimoire of the Rift | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Final Fantasy XII - Revenant Wings | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Fire Emblem - Shadow Dragon | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Flower Sun and Rain - Murder and Mystery in Paradise | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Fossil Fighters | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Fossil Fighters - Champions | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Front Mission | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Fullmetal Alchemist - Dual Sympathy | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Fullmetal Alchemist - Trading Card Game | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| GRID | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Geometry Wars - Galaxies | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Ghost Trick - Phantom Detective | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Golden Sun - Dark Dawn | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| GoldenEye 007 | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Grand Theft Auto - Chinatown Wars | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Guitar Hero - On Tour | Unable to test | Required Guitar Grip accessory unavailable; gameplay test blocked. | — |
| Guitar Hero - On Tour - Decades | Unable to test | Required Guitar Grip accessory unavailable; gameplay test blocked. | — |
| Guitar Hero - On Tour - Modern Hits | Unable to test | Required Guitar Grip accessory unavailable; gameplay test blocked. | — |
| Harry Potter and the Deathly Hallows - Part 1 | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Harry Potter and the Deathly Hallows Part 2 | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Harry Potter and the Goblet of Fire | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Harry Potter and the Half-Blood Prince | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Harry Potter and the Order of the Phoenix | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Harvest Moon - Frantic Farming | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Harvest Moon - L'Archipel du Soleil | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Harvest Moon DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Harvest Moon DS - Island of Happiness | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Harvest Moon DS Cute | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Henry Hatsworth in the Puzzling Adventure | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Heroes of Mana | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Hotel Dusk - Room 215 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Infinite Space | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| InuYasha - Secret of the Divine Jewel | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Iron Man | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Iron Man 2 | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Izuna - Legend Of The Unemployed Ninja | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Izuna 2 - The Unemployed Ninja Returns | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Jake Hunter - Detective Chronicles | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Jake Hunter Detective Story - Memories of the Past | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Justice League Heroes | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Kamen Rider - Dragon Knight | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Kingdom Hearts - 358-2 Days | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Kingdom Hearts - Re-Coded | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Kirby - Canvas Curse | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Kirby - Mass Attack | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Kirby - Squeak Squad | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Kirby Super Star Ultra | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Knights in the Nightmare | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Konami Classics Series - Arcade Hits | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| LEGO Batman - The Videogame | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| LEGO Batman 2 - DC Super Heroes | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| LEGO Battles | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| LEGO Battles - Ninjago | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| LEGO Friends | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| LEGO Harry Potter - Years 1-4 | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| LEGO Indiana Jones - The Original Adventures | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| LEGO Indiana Jones 2 - The Adventure Continues | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| LEGO Legends of Chima - Laval's Journey | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| LEGO Marvel Super Heroes - Universe in Peril | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| LEGO Pirates of the Caribbean The Video Game | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| LEGO Rock Band | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| LEGO Star Wars - The Complete Saga | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| LEGO Star Wars II - The Original Trilogy | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| LEGO Star Wars III - The Clone Wars | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| LEGO The Lord of the Rings | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Legacy of Ys - Books I & II | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Legend of Kage 2, The | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Legendary Starfy, The | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Little Red Riding Hood's Zombie BBQ | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Lock's Quest | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Lord of the Rings - Conquest, The | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Lost In Blue 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Lost in Blue | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Lost in Blue 3 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Lufia - Curse of the Sinistrals | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Luminous Arc | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Luminous Arc 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Lunar Knights | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Lux-Pain | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Magical Starsign | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Magician's Quest - Mysterious Times | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Mario & Luigi - Bowsers Inside Story | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Mario & Sonic aux Jeux Olympiques d'Hiver | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Mario Hoops - 3 On 3 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Mario Kart DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Mario Party DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Mario Vs. Donkey Kong 2 - March Of The Minis | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Mario and Luigi - Partners in Time | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Mario and Sonic at the Olympic Games | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Mario vs. Donkey Kong - Mini-Land Mayhem | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Marvel Nemesis - Rise of the Imperfects | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Marvel Ultimate Alliance 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Mazes of Fate DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| MechAssault - Phantom War | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| MegaMan Battle Network 5 - Double Team DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| MegaMan Star Force - Dragon | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| MegaMan Star Force - Leo | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| MegaMan Star Force - Pegasus | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| MegaMan Star Force 2 - Zerker x Ninja | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| MegaMan Star Force 2 - Zerker x Saurian | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| MegaMan ZX | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. Earlier development testing required entering gameplay for return. | — |
| MegaMan ZX - Advent | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| MegaMan Zero Collection | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Megaman Star Force 3 - Black Ace | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Megaman Star Force 3 - Red Joker | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Metal Slug 7 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Meteos | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Meteos - Disney Magic | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Metroid Prime Hunters | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Metroid Prime Pinball | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Might & Magic - Clash of Heroes | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Monster Racers | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Monster Rancher | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Monster Tale | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Moon | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Myst | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| N+ | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Nanostray | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Nanostray 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Naruto - Ninja Council 3 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Naruto - Ninja Destiny | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Naruto - Path Of The Ninja | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Naruto - Path of the Ninja 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Naruto Shippuden - Ninja Council 4 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Naruto Shippuden - Shinobi Rumble | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Naruto vs. Sasuke | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Need For Speed Carbon - Own The City | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Need For Speed ProStreet | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Need for Speed - Nitro | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Need for Speed - Undercover | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Need for Speed - Underground 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Need for Speed Most Wanted | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| New Super Mario Bros. | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Nine Hours, Nine Persons, Nine Doors | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Ninja Gaiden Dragon Sword | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Ninjatown | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Nintendogs - Chihuahua & Friends | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Nintendogs - Dachshund & Friends | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Nintendogs - Dalmatian & Friends | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Nostalgia | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Ontamarama | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Ookami Den | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Orcs & Elves | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Panzer Tactics DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Peggle - Dual Shot | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Phantasy Star Zero | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Phoenix Wright - Ace Attorney | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Phoenix Wright - Ace Attorney Trials And Tribulations | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Phoenix Wright Ace Attorney - Justice For All | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Picross 3D | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Picross DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Planet Puzzle League | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Plants vs. Zombies | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Pokemon - Black Version | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Pokemon - HeartGold Version | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon - SoulSilver Version | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon - White Version | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Pokemon Conquest | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Pokemon Dash | Boot failure | White screens at boot; hotkey return could not be tested. Cause not isolated against upstream. | — |
| Pokemon Diamond | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon Mystery Dungeon - Blue Rescue Team | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon Mystery Dungeon - Explorers of Darkness | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon Mystery Dungeon - Explorers of Sky | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon Mystery Dungeon - Explorers of Time | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon Pearl | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon Platinum Version | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon Ranger | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon Ranger - Guardian Signs | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon Ranger - Shadows of Almia | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon Trozei! | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Pokemon White Version 2 | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Prince of Persia - The Fallen King | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Prince of Persia - The Forgotten Sands | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Professor Layton and the Curious Village | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Professor Layton and the Diabolical Box | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Professor Layton and the Last Specter | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Professor Layton and the Unwound Future | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Puyo Pop Fever | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Puzzle Quest - Challenge of the Warlords | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Puzzle Quest - Galactrix | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Puzzle Quest 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Radiant Historia | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Resident Evil - Deadly Silence | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Retro Game Challenge | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Rhapsody - A Musical Adventure | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Rhythm Heaven | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Ridge Racer DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Rondo of Swords | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Rune Factory - A Fantasy Harvest Moon | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Rune Factory 2 - A Fantasy Harvest Moon | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Rune Factory 3 - A Fantasy Harvest Moon | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| SNK Vs. Capcom - Card Fighters DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Scribblenauts | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Scurge - Hive | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Secret Files - Tunguska | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Shin Megami Tensei - Devil Survivor | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Shin Megami Tensei - Devil Survivor 2 | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Shin Megami Tensei - Strange Journey | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Sid Meier's Civilization Revolution | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Solatorobo Red the Hunter | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Sonic Chronicles - The Dark Brotherhood | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Sonic Classic Collection | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Sonic Colors | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Sonic Rush | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Sonic Rush Adventure | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Sonic and Sega All Stars Racing | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Space Invaders Extreme | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Space Invaders Extreme 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Spectrobes | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Spectrobes - Beyond the Portals | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Spider-Man - Battle for New York | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Spider-Man - Friend or Foe | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Spider-Man - Shattered Dimensions | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Spider-Man - Web of Shadows | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Spider-Man 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Spider-Man 3 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Star Trek - Tactical Assault | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Star Wars - Battlefront - Elite Squadron | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Star Wars - Lethal Alliance | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Star Wars - The Clone Wars - Jedi Alliance | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Star Wars - The Clone Wars - Republic Heroes | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Star Wars - The Force Unleashed | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Star Wars - The Force Unleashed II | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Star Wars Episode III - Revenge of the Sith | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Sudoku Gridmaster | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Suikoden - Tierkreis | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Super Mario 64 DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Super Princess Peach | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Super Scribblenauts | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| THOR God of Thunder | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| TMNT | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Teenage Mutant Ninja Turtles - Arcade Attack | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Teenage Mutant Ninja Turtles 3 - Mutant Nightmare | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Tenchu Dark Secret | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Tetris DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Tetris Party Deluxe | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| The Legend Of Zelda - Phantom Hourglass | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| The Legend of Zelda - Spirit Tracks | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| The Lord of the Rings - Aragorn's Quest | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Tony Hawk's American Sk8land | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Tony Hawk's Downhill Jam | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Tony Hawk's Motion | Unable to test | Required motion accessory unavailable; no reset from accessible screen; gameplay test blocked. | — |
| Tony Hawk's Proving Ground | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| TrackMania DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Transformers - Autobots | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Transformers - Dark of the Moon - Autobots | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Transformers - Dark of the Moon - Decepticons | No response | Boots normally; hotkey does nothing; game remains responsive. | — |
| Transformers - Decepticons | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Transformers - Revenge of the Fallen - Autobots Version | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Transformers - Revenge of the Fallen - Decepticons Version | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Transformers Animated - The Game | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Trauma Center - Under the Knife | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Trauma Center - Under the Knife 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Ultimate Mortal Kombat | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Ultimate Spider-Man | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Viewtiful Joe - Double Trouble! | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Wacky Races - Crash & Dash | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Wario - Master of Disguise | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Wario Ware - Do It Yourself | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| WarioWare Touched! | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Welcome to Animal Crossing - Wild World | Partial | Returns to Pico, but game list is empty; return/relaunch cycle fails. | — |
| Worms - Open Warfare | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Worms - Open Warfare 2 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Yoshi Touch & Go | Pass (delayed) | Returns during gameplay; a request before gameplay returns when the game starts. | — |
| Yoshi's Island DS | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Yu-Gi-Oh! - Nightmare Troubadour | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Yu-Gi-Oh! - World Championship 2007 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Yu-Gi-Oh! - World Championship 2008 | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Yu-Gi-Oh! 5D's - World Championship 2010 - Reverse of Arcadia | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Yu-Gi-Oh! GX - Spirit Caller | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
| Zoo Keeper | Pass | Launch → hotkey return → relaunch; inferred from completed alphabetical run. | — |
