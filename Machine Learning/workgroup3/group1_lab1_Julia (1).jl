using Pkg


Pkg.add("DataFrames")
Pkg.add("Dates")
Pkg.add("CategoricalArrays")
Pkg.add("RData")
Pkg.add("Distributions")
Pkg.add("Gadfly")
Pkg.add("Plots")
Pkg.add("RDatasets")
Pkg.add("Compose")

using DataFrames
using Dates
using Statistics,RData  #upload data of R format 
using CategoricalArrays # categorical data
using Gadfly
using Plots

rdata_read = load("../../data/wage2015_subsample_inference.RData")
data = rdata_read["data"]
names(data)
println("Number of Rows : ", size(data)[1],"\n","Number of Columns : ", size(data)[2],) #rows and columns

Z = select(data, ["wage","lwage","sex","shs","hsg","scl","clg","ad","ne","mw","so","we","exp1"])
#wage lwage sex shs hsg scl clg ad exp1
data_female = filter(row -> row.sex == 1, data)
Z_female = select(data_female,["wage","lwage","sex","shs","hsg","scl","clg","ad","ne","mw","so","we","exp1"] )

data_male = filter(row -> row.sex == 0, data)
Z_male = select(data_male,["wage","lwage","sex","shs","hsg","scl","clg","ad","ne","mw","so","we","exp1"] )

means = DataFrame( variables = names(Z), All = describe(Z, :mean)[!,2], Men = describe(Z_male,:mean)[!,2], Female = describe(Z_female,:mean)[!,2])


Gadfly.plot(Z, Coord.cartesian(xmin=0, xmax=8),
    layer(x = "lwage", Geom.density , color=[colorant"black"]),
    layer(x = "lwage", Geom.histogram(bincount=30, density=true, limits=(min=0,)),
    color=[colorant"bisque"]),
    Guide.title("Logarithm of hourly wages")
)

using Gadfly, Distributions
Z1=copy(Z)
Z1[!,:sex] = string.(Z[!,:sex]) 
replace!(Z1.sex, "1.0" => "Female")
replace!(Z1.sex, "0.0" => "Male")
rename!(Z1, "sex" => "Gender")
Gadfly.plot(Z1, x = "lwage", color="Gender", Geom.density, style(line_width=3mm), 
    Guide.title("Logarithm of hourly wages by gender"),
    Theme(grid_color = colorant"white", grid_color_focused = colorant"white")
)


p1=Gadfly.plot(Z_female, Coord.cartesian(xmin=0, xmax=8),
    layer(x = "lwage", Geom.density , color=[colorant"black"]),
    layer(x = "lwage", Geom.histogram(bincount=25, density=true, limits=(min=0,)),
    color=[colorant"moccasin"]),
    Guide.title("Logarithm of female wages"))
p2=Gadfly.plot(Z_male, Coord.cartesian(xmin=0, xmax=8),
    layer(x = "lwage", Geom.density , color=[colorant"black"]),
    layer(x = "lwage", Geom.histogram(bincount=25, density=true, limits=(min=0,)),
    color=[colorant"skyblue"]),
    Guide.title("Logarithm of male wages"))
gridstack([p1 p2])

using Compose
ZX=copy(Z1)
insertcols!(ZX,3
    ,:Freq => 1)  
ZX=combine(groupby(ZX, [:Gender]),:Freq=>sum=>:Frequency)

Gadfly.plot(ZX, x=:Gender,y=:Frequency,color=:Gender, Geom.bar(position=:dodge),
    Theme(bar_spacing=2cm, minor_label_font_size = 3.5mm),
    Scale.color_discrete_manual("pink","steelblue"),
    Guide.xticks(orientation=:horizontal),
    Guide.colorkey(""),
    Guide.yticks(ticks=[0,1000,2000,3000])
)

Z2 = copy(Z1)
replace!(Z2.hsg, 1 => 2)
replace!(Z2.scl, 1 => 3)
replace!(Z2.clg, 1 => 4)
replace!(Z2.ad,  1 => 5)
Z2=select(Z2,:wage,:lwage,:Gender,:shs,:hsg,:scl,:clg,:ad,:ne,:mw,:so,:we,:exp1,[:shs, :hsg, :scl, :clg, :ad] => (+) => :EducationLevel)

Z2[!,:EducationLevel] = string.(Z2[!,:EducationLevel]) 
replace!(Z2.EducationLevel, "1.0" => "A_SomeHighschool")
replace!(Z2.EducationLevel, "2.0" => "B_HighschoolGraduate")
replace!(Z2.EducationLevel, "3.0" => "C_SomeCollege")
replace!(Z2.EducationLevel, "4.0" => "D_CollegeGraduate")
replace!(Z2.EducationLevel, "5.0" => "E_AdvancedDegree")
select(Z2,:lwage,:shs,:scl,:hsg,:clg,:ad,:EducationLevel)

p3=Gadfly.plot(Z2, x=:EducationLevel, y=:lwage, Geom.boxplot,
    Theme(default_color="MidnightBlue", minor_label_font_size = 2.2mm),
    Scale.x_discrete(levels=levels(Z2.EducationLevel)),
    Guide.xticks(orientation=:horizontal)
)
p3

Gadfly.plot(Z2, x=:Gender, y=:lwage, color=:EducationLevel,
    Scale.x_discrete(levels=["Female", "Male"]),
    Geom.boxplot,
    Guide.manual_color_key("Schooling Level", ["College_Graduate", "Highschool_Graduate","Advanced_Degree","Some_College","Some_Highschool"]),
    Theme(key_position=:none),
)

using Compose
Z3=copy(Z2)
insertcols!(Z3,4
    ,:Freq => 1)  
Z3=combine(groupby(Z3, [:Gender,:EducationLevel]),:Freq=>sum=>:Frequency)

p5 =Gadfly.plot(Z3, x=:EducationLevel,y=:Frequency, color=:Gender, Geom.bar(position=:stack),
    Scale.x_discrete(levels=levels(Z2.EducationLevel)),
    Theme(bar_spacing=4mm,grid_color = colorant"white", grid_color_focused = colorant"white", minor_label_font_size = 2.5mm),
    Guide.xticks(orientation=:vertical),
    )
p6 = title(render(p5), "Education Levels by Gender", Compose.fontsize(14pt))


Z2=rename!(Z2, "exp1" => "Experience")

Gadfly.plot(Z2, x=:"Experience", Coord.cartesian(xmin=0, xmax=55),
    Geom.histogram(bincount=30, density=false, limits=(min=0,)),
    color=[colorant"lightgreen"],
    Guide.ylabel("Frequency"),
)

p8= Gadfly.plot(Z2, Coord.cartesian(xmin=0, xmax=55),
    layer(x = "Experience", Geom.density , color=[colorant"black"]),
    layer(x = "Experience", Geom.histogram(bincount=30, density=true, limits=(min=0,)),
    color=[colorant"bisque"]),
)

Gadfly.plot(Z2, x = "Experience", color="Gender", Geom.histogram(bincount=15, density=true), style(line_width=3mm),
    Theme(grid_color = colorant"white", grid_color_focused = colorant"white"),
    Guide.title("Years of experience by gender")
)

p1=Gadfly.plot(Z_female, Coord.cartesian(xmin=0, xmax=55),
    layer(x = "exp1", Geom.density , color=[colorant"black"]),
    layer(x = "exp1", Geom.histogram(bincount=25, density=true, limits=(min=0,)),
    color=[colorant"moccasin"]),
    Guide.title("Female experience"),
    Guide.xlabel("Experience")
)
p2=Gadfly.plot(Z_male, Coord.cartesian(xmin=0, xmax=55),
    layer(x = "exp1", Geom.density , color=[colorant"black"]),
    layer(x = "exp1", Geom.histogram(bincount=25, density=true, limits=(min=0,)),
    color=[colorant"skyblue"]),
    Guide.title("Male Experience"),
    Guide.xlabel("Experience")
)
gridstack([p1 p2])

Gadfly.plot(Z2, x="Experience",y="lwage"
)
    

Gadfly.plot(Z2, x="Experience",y="lwage",color="Gender",
    Scale.color_discrete_manual("pink","steelblue"),
    Guide.ylabel("Log-wage")
)

Z4=hcat(data, data.lwage, makeunique=true)
Z4=filter(row->row.sex in [0], Z4)
Z4=filter(row->row.hsg in [1] || row.clg in [1], Z4)
A=filter(row->row.hsg in [1], Z4)
B=filter(row->row.clg in [1], Z4 )

A=combine(groupby(A, [:exp1]),:x1=>mean=>:mean_lwage)
A=insertcols!(A,3
    ,:hsg => 1) 
A=insertcols!(A,4
    ,:clg => 0)

B=combine(groupby(B, [:exp1]),:x1=>mean=>:mean_lwage)
B=insertcols!(B,3
    ,:hsg => 0)
B=insertcols!(B,4
    ,:clg => 1)
Z5=vcat(A,B)

RM = @formula(mean_lwage ~ hsg + exp1)
RM_model = lm(RM,Z5)
RM_est = GLM.coef(RM_model)
RM_predict = predict(RM_model)

Graph_RM=hcat(Z5,RM_predict)

Gadfly.plot(Graph_RM,x=:"exp1", y=:"mean_lwage")

p2 = plot(Graph_RM, x=:x, y=:y,  Geom.point,  Scale.x_asinh, Scale.y_log,
     intercept=[148], slope=[-0.5], abline)



#install all the package that we can need
Pkg.add("Lathe")
Pkg.add("GLM") # package to run models 
Pkg.add("StatsPlots")
Pkg.add("MLBase")
Pkg.add("Tables")
Pkg.add("CovarianceMatrices") # robust standar error 
# Load the installed packages
using DataFrames
using CSV
using Tables
using Lathe
using GLM
using CovarianceMatrices

function coefplot(m)
        DF  = DataFrame(x=coefnames(m),y=coef(m), mins=confint(m)[:,1], maxs=confint(m)[:,2])[2:end,:] #no intercept
        Gadfly.plot(DF, x=:x, y=:y, ymin=:mins, ymax=:maxs,
        Geom.point, Geom.errorbar,
        Guide.xlabel(""),
        Guide.ylabel("")
        )
end

nocontrol_model = lm(@formula(lwage ~ sex), data)
nocontrol_est = GLM.coef(nocontrol_model)[2]
nocontrol_se = GLM.coeftable(nocontrol_model).cols[2][2]
nocontrol_se1 = stderror(HC1(), nocontrol_model)[2]
println("The estimated gender coefficient is ", nocontrol_est ," and the corresponding robust standard error is " ,nocontrol_se1)

coefplot(nocontrol_model)

flex = @formula(lwage ~ sex + (exp1+exp2) * (clg))
control_model = lm(flex , data)
control_est = GLM.coef(control_model)[2]
control_se = GLM.coeftable(control_model).cols[2][2]
control_se1 = stderror( HC0(), control_model)[2]


println("Coefficient for OLS with controls " , control_est, "robust standard error:", control_se1)

coefplot(control_model)

# models
# model for Y
flex_y = @formula(lwage ~ (exp1+exp2+exp3+exp4) * (shs+hsg+scl+clg+occ2+ind2+mw+so+we))
flex_d = @formula(sex ~ (exp1+exp2+exp3+exp4) * (shs+hsg+scl+clg+occ2+ind2+mw+so+we))

# partialling-out the linear effect of W from Y
t_Y = residuals(lm(flex_y, data))

# partialling-out the linear effect of W from D
t_D = residuals(lm(flex_d, data))

data_res = DataFrame(t_Y = t_Y, t_D = t_D )
# regression of Y on D after partialling-out the effect of W

partial_fit = lm(@formula(t_Y ~ t_D), data_res)

partial_est = GLM.coef(partial_fit)[2]

# standard error
partial_se = GLM.coeftable(partial_fit).cols[2][2]

partial_se1 = stderror( HC0(), partial_fit)[2]

#condifence interval
GLM.confint(partial_fit)[2,:]

println("Coefficient for D via partiallig-out ", partial_est, " robust standard error:", control_se1 )

coefplot(partial_fit)

DataFrame(modelos = [ "Without controls", "full reg", "partial reg" ], 
Estimate = [nocontrol_est,control_est, partial_est], 
StdError = [nocontrol_se1,control_se1, partial_se1])




