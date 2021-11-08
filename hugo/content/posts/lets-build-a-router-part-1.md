---
author: "Aashray"
include_toc: true
description: "A few words here and there about what I'm up to."
title: "Lets Build A Router Part 1"
date: 2021-10-31T17:15:06-07:00
draft: false
---

***Today I’m going to describe the first steps of how I set up a virtual router, to connect multiple private local access networks of virtual machines together, and eventually, to the Internet.***

*Obviously, we first need to understand, what is a router? It’s something we all have in our homes, but in the eyes of most, is just a magical tunnel to the Internet.*

![your router visualized gif](https://media.giphy.com/media/IWp7xsHXRjOZ1hsg5y/giphy.gif)

A router is really just a computer, which is specially configured to
enable a set of devices to use a shared connection to the public internet (e.g., through a single modem/broadband connection), as well as to communicate with each other, independently of the Internet.

Of course, like always I can’t divulge the entire path to building this router in just this post (partially so you’ll come back for the next part, partially because I haven’t finished this experiment myself!). Today we’ll make some headway on configuring our router and virtual networks, and on the way will learn about setting up Linux VMs, virtual networks, and network interface configuration.

![let the games begin gif](https://media.giphy.com/media/xT0xevozBTg7ChpL44/giphy.gif)

Note: I’ve chosen to use Hyper-V for configuring virtual networking/machine management, similar configuration can be accomplished with VirtualBox, or any other technology with supports network and compute virtualization

### VM Setup

There’s countless articles on the internet for how to set up an Ubuntu VM using Hyper-V, such as this one, so I won’t drone on about this step, I’ll just specify the exact VMs I am setting up for my configuration, and briefly, the virtual networks.

I’ve created 7 VMs, which I refer to as RedA, RedB, BlueA, BlueB, GreenA, GreenB, and Router. Each of the sets of color is the pair of VMs which I will isolate to their own private network (more on how to do this in the next section). The last VM, as the name suggests, is the router, which will be hooked up to each private network, and to the Internet.

*Each of these VMs is running Ubuntu Server LTS, which has an ISO available here*

### Private Network Setup

For my network configuration, I’ve set up 3 isolated networks, each including a pair of VMs, connected to each other by a virtual switch. A switch is simply an input-output device, which routes traffic to and from hosts connected to the switch, via ethernet. You may have seen a switch like below before in your home or work network setup, creating a network of devices connected to the switch via ethernet cables.

*Put simply, a virtual switch accomplishes the same task of routing traffic between connected hosts, virtualized on your own computer, amazing!*

A virtual switch in this scenario enables us to set up a VLAN, or a virtual local area network, where a local area network is a network partitioned and isolated at the data link/L2 layer of the network stack, or sometimes referred to as the ethernet layer (as this is the predominant L2 protocol).

A virtual LAN accomplishes the same effect as a LAN, but by manipulating physical network interfaces with additional software logic, modifying the frames passing through these network interfaces, and giving the appearance of there being a separate physical network connecting the devices in this VLAN, when that is not necessarily the case. Thus, we are able to partition our 3 pairs of VMs, while running all 6 VMs on the same host machine, pretty sweet!

![hyperv1 image](/hyperv1.png)

We can create a private virtual switch in Hyper-V as seen above, by opening the Virtual Switch Manager, in the Hyper-V Manager

In the Virtual Switch Manager, we can create a new virtual network switch, specifying that we wish to make the network private.

We can then configure a network adapter on each of the VMs we want to connect to that switch, under the VM settings, by adding a Network Adapter under the list of hardware components to add, and specifying the respective network switch to hook this adapter up to.

![hyperv2 image](/hyperv2.png)

A network adapter is a hardware component of your computer which allows it to access a computer network, via a link-layer protocol. A common example that most would be familiar with is a Wi-Fi network adapter, which manages a device’s ability to access Wi-Fi networks.

In our case, we are configuring ethernet network adapters, which manage a device’s ability to access a network via ethernet. By configuring an ethernet network adapter for a VM onto a particular virtual switch, we can imagine an ethernet cable running from this computer, into the switch, similar to the picture below.

![computer switch image](/switch_and_computer.png)

### Visualizing the Network

At this point, we have configured 3 switches, Red, Green, and Blue, and configured our 6 VMs to each have a virtual ethernet connection to their respective switches.

![vlan visual 1 image](/vlan_visual.png)

*The key takeaway from the existing configuration is that intra-network communication is possible, but inter-networking is not, and as a result, none of these private networks can access the Internet.*

### Hooking up the router

As we described briefly, a router is a device which serves as a courier to an Internet connection, multiplexing the input from a set of devices to the single Internet connection, and routing the response data streams to these devices.

For a router to be able to accomplish its goal, it must first have a connection with any devices which intend to utilize it. In a typical home set up, this connection would be established either over Wi-Fi, or ethernet. In our case, we are going to use ethernet, and assign 3 network adapters on the router, 1 per private switch, which will allow all VMs to communicate with the router.

We also need to create an external switch, and assign to it the host’s ethernet connection, then configure a network adapter of the router onto this switch, resulting in a switch which can route between the router and the host’s ethernet. This means, in addition to being able to communicate with each private network the router can now communicate with the Internet.

![hyperv3 image](/hyperv3.png)

We now have a network configuration like below. (each arrow is a link from the corresponding switch, to the router, the router can be imagined as being inside of all 4 of these switches), which chains each of our private networks, via the router, to the Internet.

![vlan visual 2 image](/vlan_visual2.png)

### We have a network!

We now have a fully formed ethernet/L2 network configuration, with switches hooking up each of our VLANs to the router, and a switch connecting the router to the Internet, which we can refer to as a switched ethernet.

Ethernet employs MAC (media access control) addresses, which (mostly) uniquely identify network interfaces, for example see the MAC addresses below for each of our routers’ interfaces, which have addresses of the form XX:YY:ZZ… Each of the tags eth# is the name of a network interface on the machine, with the link/ether tags indicating that these MAC addresses are the link-layer, or ethernet layer address of the interface. These MAC addresses are generally static, and typically are burned into the network interface cards in the case of physical machines.

![terminal image](/terminal1.png)

### Getting some IP

You may be asking at this point, are we done? We have addresses to identify network interfaces, and a channel through the switch configuration that lets the router route traffic between our networks, and to the Internet, right? In theory, we could, and this ethernet configuration could suffice (at least to connect our private networks), but in practice, it’s a bit more complex than that, as the Internet is driven by a protocol which builds on top of what we’ve got so far, known as IP.

To reach our goal of building a router as we know it, we’ll need to take the next step, and learn how to configure IP addresses for our network interfaces, as well as IP routing, both of which we’ll talk about next time.

