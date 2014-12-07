using Gadfly, DataFrames
num_coeff = [5,10,15,25,50];
accuracy = Array[[81,84,86,88,90], [81,84,86,88,91], [72,83,89,89,92], [62,70,72,72,72]];

l1 = DataFrame(x=num_coeff, y=accuracy[1], Sets="NS / NS (RGB)");
l2 = DataFrame(x=num_coeff, y=accuracy[2], Sets="NS / S (RGB)");
l3 = DataFrame(x=num_coeff, y=accuracy[3], Sets="NS / NS (cropped gray)");
l4 = DataFrame(x=num_coeff, y=accuracy[4], Sets="NS / S (cropped gray)");
df = vcat(l1, l2, l3, l4);

p = plot(df, x="x", y="y", color="Sets", Geom.line, Geom.point, 
  Guide.xlabel("Number of Coefficients Used (k)"),
  Guide.ylabel("Accuracy"), 
  Guide.title("Accuracy vs Number of Coefficients Used for 50 Training Images"),
  Theme(key_title_font_size=15pt, major_label_font_size=19pt,
        minor_label_font_size=15pt, key_label_font_size=15pt,
        major_label_color=color("black"), minor_label_color=color("black"),
        line_width=2pt),
  Guide.xticks(ticks=num_coeff));
draw(PNG("accuracy_k.png", 10inch, 5inch), p);

num_coef = [5,10,15,25,50,70,90,100];
acc = [63.2,69,70.7,75.5,82.1,83.8,85.5,85.1];
p = plot(x=num_coef, y=acc, Geom.line, Geom.point, 
  Guide.xlabel("Number of Coefficients Used (k)"),
  Guide.ylabel("Accuracy"), 
  Guide.title("Accuracy vs Number of Coefficients Used for LFW"),
  Theme(key_title_font_size=15pt, major_label_font_size=19pt,
    minor_label_font_size=15pt, key_label_font_size=15pt,
    major_label_color=color("black"), minor_label_color=color("black"),
    line_width=2pt),
  Guide.xticks(ticks=num_coef));
draw(PNG("accuracy_k_lfw.png", 10inch, 5inch), p);
