=========================
Simple implementation of Linked List in MIPS
=========================
Anh Vu L Nguyen
April 2015

This program is a simple programs that use MIPS assembly programming language.
The program is a linked list with several basic capabilities, such as traversing the whole list, adding in new nodes, deleting nodes.
Users can also print the whole linked list out with debug method.
The current limitation for input string is less than 11 characters. This can be changed easily based on allocation of space for new node (even though it would also mean changing the offset for a number of procedures).

The problem I have with this is there’s memory leaked with this implementation of Linked List. If one uses this to add about 20 nodes, it should not be a problem. However, if one uses this to add 10,000 nodes, there might be a problem with memory leak. I do not intend to dig deeper to incorporate garbage collection, for now.

Program is done in MARS 4.5.
Any queries can be directed to vu.nguyen@skidmore.edu or anhvu.nguyenlam@gmail.com
