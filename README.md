# ESP32 WLED driver with Ethernet

This is meant to be a small and simple ethernet-enabled WLED driver box based on the [WT32-ETH01 board](https://aliexpress.com/w/wholesale-WT32%2525252deth01.html). These are available for approx. 7 bucks, so the whole box can end up in the 10 bucks range. (Power supply not included)

It can handle 5V and up to 10A using a barrel-jack power supply [like these](https://www.amazon.com/s?k=power+supply+5V+10A+barrel+jack) and can be flashed with [WLED](https://kno.wled.ge)
There is no fuse, so only use power supply units that are reasonably safe to use.

You can connect to up to 2 or 4 WS2812 LED strips. (Note that using 12V strips should be possible, too, by interrupting the 5V line in the LED connector and supplying LED strip and ESP32 separately.)

## Buying the parts

You will need:

- WT32-ETH01 board
- 3D-printed case (see below; beware: there are differently-sized WT32-ETH01s available, so measure yours first!)
- 2x male 3-pin LED connectors with wires attached (approx. 10-13 cm should be fine)
- some shrinking tube
- a 5.5x2.1 or 5.5x2.5 panel mount barrel jack socket like this ![image of socket](jack.jpg)
- approx 20cm of cable that is capable of handling 10A; (ideally 10cm red and 10cm black)
- small cable ties that are <= 5mm at their head
- a small connector capable of handling 10A
	- [XT-30](https://duckduckgo.com/?q=xt-30+connector&iar=images&iax=images&ia=images) can handle the current, but is too large for the metal holding ring of the barrel jack socket. You can cut the ring open on one side with a dremel, though.
	- [JST-RCY](https://duckduckgo.com/?hps=1&q=jst-rcy&iax=images&ia=images) is only rated up to 3-5A and gets really hot (around 75°C), do not use.
	- 2mm banana plugs could work (untested)

## Printing the case

- First, measure the PCB's long side (without the ethernet connector); it should be around 55mm, but there are at least two different versions with different lengths.
- Configure `board_y` in `case.scad` accordingly.
- Decide whether how many LED connectors you want to use. If it's 2x, set `cable_slot_xlen = 4`, for 4x, `cable_slot_xlen = 7` seems like a good fit.
- Render the STL using [OpenSCAD](https://openscad.org) and print it.

## Assembling everything

TODO cabling plan

- **Important:** Test all your cables' and connector resistances, e.g. by running 5A through them using a lab power supply and measuring the voltage (resistance = voltage / current). They should not exceed 10mOhm per 10cm, and not 5mOhm per connector. Less is better.
- First, break the **pin headers** into suitable pieces and **solder them on the top side** of the WT32-ETH01 boards as indicated in the picture above.
- Then, **cut the cables** to the appropriate lengths (with isolation) and remove 3mm of isolation on the solder-to-board ends, and 5mm on the solder-to-cable ends.
- **Solder the cables together** as shown in the image; the orientations are important.
- Don't forget to apply **shrinking tube**.
- *Only then* **solder the cables to the WT32-ETH01** and one connector end as indicated by the pictures above.
- **Solder** the remaining cables to the **barrel jack socket** and the other connector.
- Connect a **serial adapter** to the pin headers of the WT32-ETH01 and [**flash WLED**](https://kno.wled.ge/basics/install-binary/) (use an ethernet-enabled firmware!). You may want to connect the barrel jack temporarily for this.
- Insert the barrel jack socket and the WT32-ETH01 **into the printed case**, connect the connectors.
- Guide the LED strip connectors to the back end's cable cutout, push them in slightly and mark the spot where the cables are in the ~5mm chamber.
- Firmly **apply a cable tie** at the marked spot, and place the cable tie's head into that 5mm chamber. Ensure that it acts as a pull/push **strain relief** for the cable.
- Put on the case's top.
- Done :)

## Configuring WLED

Upon first startup, you should see a WiFi called "WLED"; the ethernet port is not yet operable. The password might be `wled1234`, but _shhh_ don't tell anyone.

Go to LED settings, and configure two (or more) LED outputs on GPIO 4 and 5.

Go to WiFi settings, scroll to the bottom and enable ethernet; configure the WT-ETH01 variant of ethernet.

All your LEDs are belong to us!
