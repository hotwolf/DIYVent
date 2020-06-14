//###############################################################################
//# DIYVent - Main Assembly                                                     #
//###############################################################################
//#    Copyright 2020 Dirk Heisswolf                                            #
//#    This file is part of the DIYVent project.                                #
//#                                                                             #
//#    This project is free software: you can redistribute it and/or modify     #
//#    it under the terms of the GNU General Public License as published by     #
//#    the Free Software Foundation, either version 3 of the License, or        #
//#    (at your option) any later version.                                      #
//#                                                                             #
//#    This project is distributed in the hope that it will be useful,          #
//#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
//#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
//#    GNU General Public License for more details.                             #
//#                                                                             #
//#    You should have received a copy of the GNU General Public License        #
//#    along with this project.  If not, see <http://www.gnu.org/licenses/>.    #
//#                                                                             #
//#    This project makes use of the NopSCADlib library                         #
//#    (see https://github.com/nophead/NopSCADlib).                             #
//#                                                                             #
//###############################################################################
//# Description:                                                                #
//#   Assembly of the DIY Vent.                                                 #
//#                                                                             #
//###############################################################################
//# Version History:                                                            #
//#   June 14, 2020                                                              #
//#      - Initial release                                                      #
//#                                                                             #
//###############################################################################

include <NopSCADlib/lib.scad>
//include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/ball_bearings.scad>

//$explode=1;
//$vpr = [70,0,110];
//$vpt = [0, 0, 0];
   
//! This is a filament guide for Prusa MK3(S) printers . 
// ![inside](doc/DIYLB.gif?raw=true)


//Wooden frame
module frame() {
    
    color("brown")
    difference() {
        translate([0,0,-1]) cube([31,31,2], center=true);
        translate([0,0,-1]) cube([27,27,4], center=true);
    }    
}

//Molds
module mold(height=13.5,lowerWidth=27,upperWidth=10) {
    Points = [
        [ lowerWidth/2,           lowerWidth/2,      0 ],          //0
        [-lowerWidth/2,           lowerWidth/2,      0 ],          //1
        [-lowerWidth/2,          -lowerWidth/2,      0 ],          //2
        [ lowerWidth/2,          -lowerWidth/2,      0 ],          //3
        [ upperWidth/(2*sqrt(2)), upperWidth/(2*sqrt(2)),height],  //4
        [-upperWidth/(2*sqrt(2)), upperWidth/(2*sqrt(2)),height],  //5
        [-upperWidth/(2*sqrt(2)),-upperWidth/(2*sqrt(2)),height],  //6
        [ upperWidth/(2*sqrt(2)),-upperWidth/(2*sqrt(2)),height]]; //7
    Faces = [
        [0,1,2,3],  //bottom
        [4,5,6,7],  //top 
        [0,1,5,4],  //back
        [1,2,6,5],  //left
        [2,3,7,6],  //front
        [3,0,4,7]]; //right

    hull() {
        //Pyramid
        polyhedron(Points,Faces);
        //Cone
        cylinder(height,d1=lowerWidth,d2=upperWidth);
    }
}







//! Push three ball bearings onto the printed part. 

module main_assembly() {
    pose([70, 0, 110], [0,0,0])
    assembly("main") {

 
    }
}

if($preview) {
    
    
    
    
   frame(); 
   mold(); 
    
    
    
   main_assembly();
}