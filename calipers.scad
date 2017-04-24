module arc(startAngle, endAngle, radius) {
    fullAngle = endAngle - startAngle;
    if (fullAngle >= 90) {
        intermediateAngle = fullAngle / 2;
        union() {
            arc(
                startAngle,
                startAngle + intermediateAngle,
                radius
            );
            arc(
                startAngle + intermediateAngle,
                endAngle,
                radius
            );
        }
    } else {
        overshootFactor = 2; // too lazy to figure the correct value out
        correctedRadius = overshootFactor * radius;
        intersection() {
            polygon([
                [0, 0],
                [
                    correctedRadius * cos(startAngle),
                    correctedRadius * sin(startAngle)
                ],
                [
                    correctedRadius * cos(endAngle),
                    correctedRadius * sin(endAngle)
                ]
            ]);
            circle(radius);
        }
    }
}

module shear2d(
    innerDiameter,
    maxThickness,
    minThickness = 0,
) {
    outerDiameter = innerDiameter + maxThickness + minThickness;
    offsetDistance = (outerDiameter / 2) - (innerDiameter / 2) - minThickness;
    difference() {
        translate([-offsetDistance, 0, 0]) {
            circle(d = outerDiameter, $fn = 20);
        }
        circle(d = innerDiameter, $fn = 30);  
        translate([-outerDiameter / 2 - offsetDistance, 0, 0]) { square(outerDiameter); }
    }
}

module calipers2d(
    hingeDiameter = 10,
    hingeAngle = 45,
    gaugeDiameter = 5,
    endThickness = 1,
    hingeThickness = 3,
    legThickness = 3,
    thighLength = 60,
    shinLength = 60
) {
    legAngle = hingeAngle / 2;
    shearOffsetAngle = legAngle / 4;
    shearMaxThickness = legThickness * 1.1;
    union() {
        difference() {
            difference() {
                circle(d = hingeDiameter + (hingeThickness * 2));
                circle(d = hingeDiameter);
            }
            hingeRadius = hingeDiameter / 2;
            overshoot = 2; // required to clip away wall
            arc(
                270 - hingeAngle / 2,
                270 + hingeAngle / 2,
                hingeRadius + hingeThickness * overshoot
            );
        }
        // Thigh 1
        difference() {
            rotate(180 - legAngle, [0, 0, 1]) {
                translate([-legThickness / 2, 0, 0]) {
                    square([legThickness, thighLength]);
                }
            }
            circle(d = hingeDiameter);
        }
        // Elbow 1
        translate([
            -sin(legAngle) * thighLength,
            -cos(legAngle) * thighLength,
            0
        ]) {
            circle(legThickness, $fn = 15);
        }
        // Shin 1
        translate([
            -sin(legAngle) * thighLength,
            -cos(legAngle) * thighLength,
            0
        ]) {
            rotate(180, [0, 0, 1]) {
                translate([-legThickness / 2, 0, 0]) {
                    square([legThickness, shinLength]);
                }
            }
        }
        // Shear 1
        translate([
            -sin(legAngle) * thighLength + (legThickness * 0.75),
            -cos(legAngle) * thighLength - shinLength - (gaugeDiameter / 2) - (legThickness / 2),
            0
        ]) {
            rotate(270 - shearOffsetAngle, [0, 0, 1]) {
                shear2d(gaugeDiameter, shearMaxThickness, minThickness = endThickness);
            }
        }
        // Thigh 2
        difference() {
            rotate(180 + hingeAngle / 2, [0, 0, 1]) {
                translate([-legThickness / 2, 0, 0]) {
                    square([legThickness, thighLength]);
                }
            }
            circle(d = hingeDiameter);
        }
        // Elbow 2
        translate([
            sin(legAngle) * thighLength,
            -cos(legAngle) * thighLength,
            0
        ]) {
            circle(legThickness, $fn = 15);
        }
        // Shin 2
        translate([
            sin(legAngle) * thighLength,
            -cos(legAngle) * thighLength,
            0
        ]) {
            rotate(180, [0, 0, 1]) {
                translate([-legThickness / 2, 0, 0]) {
                    square([legThickness, shinLength]);
                }
            }
        }
        // Shear 2
        translate([
            sin(legAngle) * thighLength - (legThickness * 0.75),
            -cos(legAngle) * thighLength - shinLength - (gaugeDiameter / 2) - (legThickness / 2),
            0
        ]) {
            rotate(90 + shearOffsetAngle, [0, 0, 1]) {
                rotate(180, [0, 1, 0]) {
                    shear2d(gaugeDiameter, shearMaxThickness, minThickness = endThickness);
                }
            }
        }
    }
}

module calipers(gaugeDiameter, text) {
    hingeAngle = 45;
    hingeDiameter = gaugeDiameter * 2;
    thighLength = gaugeDiameter * 5;
    shinLength = thighLength * 0.8;
    endThickness = 0.5;
    legThickness = gaugeDiameter / 3;
    hingeThickness = legThickness;
    overallWidth = legThickness * 2.5;
    textMargin = 1;
    difference() {
        linear_extrude(overallWidth) {
            calipers2d(
                hingeAngle = hingeAngle,
                hingeDiameter = hingeDiameter,
                gaugeDiameter = gaugeDiameter,
                thighLength = thighLength,
                shinLength = shinLength,
                endThickness = endThickness,
                legThickness = legThickness,
                hingeThickness = hingeThickness
            );
        }
    
        translate([
            sin(hingeAngle / 2) * thighLength + (legThickness / 3),
            -cos(hingeAngle / 2) * thighLength - (shinLength / 2),
            overallWidth / 2
        ]) {
            rotate(90, [0, 1, 0]) {
                rotate(90, [0, 0, 1]) {
                    linear_extrude(legThickness / 3) {
                        text(
                            "4G",
                            size = overallWidth - textMargin,
                            valign = "center",
                            halign = "center"
                        );
                    }
                }
            }
        }
    }
}

calipers(5, "4G");
