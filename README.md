Project for dmpro 2016
===========================

```
 ______
< sudo >
 ------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

Documents structure
--------------------

| Location | Description |
| -------- | ----------- |
| `documents/deliveries` | contains a directory per delivery. Everything that is to be delivered is placed here and is compiled into a pdf/LaTeX before delivery |
| `documents/documentation` | contains all design documents, facts and data about our system and the components used in it. |
| `documents/documentation/datasheets/` | contains datasheets for components used. |
| `documents/meetings` | contains meeting minutes from all meetings, sorted by date |
| `documents/research` | contains research notes on components, algorithms, circuits, application notes and datasheets for potential components etc. |
| `documents/todo` | task lists, with deadline |


src structure
-------------------

* **mcu**: code running on the EFM32
* **fpga**: code running on the FPGA
  * Folder for each module
* **prototyping**: code not running in final product
  * Folder for each prototype program
