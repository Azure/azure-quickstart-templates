Prerequisites:
- URL to the existing VHD file in ether a premium or standard storage account.
- Name of the existing VNET and subnet you want to connect the new virtual machine to.
  - Name of the Resource Group that the VNET resides in.

This template creates a VM from a specialized VHD and let you connect it to an existing VNET that can reside in another Resource Group then the virtual machine.

Plese note: This deployment template does not create or attach an existing Network Security Group to the virtual machine. 
