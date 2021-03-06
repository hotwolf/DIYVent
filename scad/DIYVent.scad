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

//! This is a vent cover for a 100mm exhaust hose.

include <NopSCADlib/lib.scad>
//include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/screws.scad>

//$explode=1;
//$vpr = [70,0,110];
//$vpt = [0, 0, 0];
   
//Global variables
$innerWidth    = 270;   //inner width of the base
$outerWidth    = 300;   //outer width of the base
$height        = 135;   //height without hose connector
$hcInnerWidth  =  96;   //inner diameter of the hose connector
$hcOuterWidth  = 100;   //outer diameter of the hose connector
$hcHeight      =  20;   //height of the hose connector

$screwPositions = [[142,142],[-142,142],[-142,-142],[142,-142],
                   [142,40],[142,-40],
                   [-142,40],[-142,-40],
                   [40,142],[40,-142],
                   [-40,142],[-40,-142]];
 
$screwType = M5_pan_screw;
    
//Wooden frame
module frame() {
    
    color("brown")
    difference() {
        translate([0,0,-27]) cube([340,340,54], center=true);
        translate([0,0,-30]) cube([270,270,60], center=true);
    }            
}

//Repeating shapes
//Basic mold
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

//Inner mold
module innerMold(){
    mold(height     = $height,
         lowerWidth = $innerWidth,
         upperWidth = $hcInnerWidth);
}

//Outer mold
module outerMold(){
    mold(height     = $height,
         lowerWidth = $outerWidth,
         upperWidth = $hcOuterWidth);
}

//Ring
module ring(innerWidth=98,outerWidth=100,height=20) {
    //Local variables
    thickness = outerWidth-innerWidth; //wall thickness
    cylHeight = height-(thickness/2);  //height of the cylunder shapes
    
    difference() {
        union() {
            cylinder(cylHeight,d=outerWidth);
            translate([0,0,cylHeight]) rotate_extrude() 
            translate([(innerWidth/2)+(thickness/4),0.0]) circle(d=thickness/2);
        }
        translate([0,0,-1]) cylinder(cylHeight+2,d=innerWidth);
    }
}
        
//Full vent shape
module vent_full_stl () {
//    stl("Full shape");
    
    //Local variables
    washerDiameter = washer_diameter(screw_washer($screwType));
//    washerDiameter = washer_diameter(M5_washer);
   
    color(pp1_colour)
    union() {
    
        //Main body
        difference() {
            union() {
                outerMold();
                for(pos=$screwPositions) {
                      translate([pos[0],pos[1],0]) ring(innerWidth=washerDiameter,
                                                        outerWidth=washerDiameter+4,
                                                        height=10);
                }                
             }
            union () {
                innerMold();
                cylinder($height+1,d=$hcInnerWidth);
                //translate([0,0,-5]) cube([$outerWidth,$outerWidth,10], center=true);
                for(pos=$screwPositions) {
                     translate([pos[0],pos[1],5])  screw_countersink($screwType);
                     translate([pos[0],pos[1],5])  cylinder(50,d=washerDiameter);
                     translate([pos[0],pos[1],-1]) cylinder(50,r=screw_radius($screwType));
                }                
            }     
        }
 
        //Hose connector
        translate([0,0,$height]) ring(innerWidth=$hcInnerWidth,
                                      outerWidth=$hcOuterWidth,
                                      height=$hcHeight);

        //Fins
        intersection() {
            union() {
                for(angle=[0:90:270]) {
                    rotate([0,0,angle]) translate([$hcInnerWidth/2,-2,0]) cube([$innerWidth,4,$height]);
                }
                     for(angle=[0:30:330]) {
                    rotate([0,0,angle]) translate([$hcInnerWidth/2,-1,0]) cube([$innerWidth,2,$height]);
                }
            }
            innerMold();
        }
    }
}

//Vent corner shape
module vent_corner_stl () {
    stl("vent_corner");
    
    intersection() {
        vent_full_stl();
        cube([500,500,500]);
    }
}

//Frame mounted fin
module frame_fin_stl () {
    stl("frame_fin");

    //Local variables
    washerDiameter = washer_diameter(screw_washer($screwType));
    screwDiameter  = 2*screw_radius($screwType);

    color(pp1_colour)
    difference() {
         union() {       
            translate([55,-1,-40])   cube([80,2,40]);
            translate([125,-1,-50])  cube([10,2,50]);
            translate([133,-12,-50]) cube([2,24,50]);
            
            translate([133,1,0])
            polyhedron( 
                [[0,0,0],[0,0,-50],[-4,0,-50],[0,4,-50]],
                [[0,1,3],[0,2,1],[0,3,2],[1,2,3]]);
             
            translate([133,-1,0])
            polyhedron( 
                [[0,0,0],[0,0,-50],[-4,0,-50],[0,-4,-50]],
                [[0,1,3],[0,2,1],[0,3,2],[1,2,3]]);
         }
         union() {           
            translate([130,-6,-25]) rotate([0,90,0]) cylinder(10,d=screwDiameter);
            translate([127,-6,-25]) rotate([0,90,0]) cylinder(6,d=washerDiameter);
            translate([130,6,-25])  rotate([0,90,0]) cylinder(10,d=screwDiameter);
            translate([127,6,-25]) rotate([0,90,0])  cylinder(6,d=washerDiameter);            
         }   
    }
}

//! Glue all four corners of the vent cover together.
//! Screw the cover against the wooden frame.
//! Screw fins against the inside of the wooden frame 
module main_assembly() {
    pose([70, 0, 110], [0,0,0])
    assembly("main") {

        //Cover
        for(angle=[0:90:270]) {
            rotate([0,0,angle]) explode(d=10) vent_corner_stl();
        }

        //Cover Screws
        for(pos=$screwPositions) {
          //translate([pos[0],pos[1],5]) explode(50) screw_and_washer($screwType, 20);
            translate([pos[0],pos[1],5]) explode(50) screw_and_washer(No6_screw, 20);
        }

        //Frame mounted fins
        for(angle=[0:90:270]) {
          //translate([0,0,-40])
            rotate([0,0,angle]) explode(-80) frame_fin_stl();
        }

        //Fin scews
        for(angle=[0:90:270]) {
            rotate([0,0,angle]) explode([-30,0,-80]) translate([133,-6,-25]) rotate([0,270,0]) screw_and_washer(No6_screw, 20);
            rotate([0,0,angle]) explode([-30,0,-80]) translate([133,6,-25])  rotate([0,270,0]) screw_and_washer(No6_screw, 20);            
        }
    }
}

if($preview) {
    
   frame(); 
//   innerMold(); 
//   outerMold(); 
//   ring();  
//    vent_full_stl();
//    vent_corner_stl();
    
   main_assembly();
}