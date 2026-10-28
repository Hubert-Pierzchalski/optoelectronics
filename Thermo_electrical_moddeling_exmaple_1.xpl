<plask loglevel="detail">

<geometry>
  <cartesian2d name="main" axes="x,y" left="mirror" length="1000">
    <stack>
      <rectangle name="top-layer" material="Al(0.3)GaAs:C=1e20" dx="1.5" dy="1.350"/>
      <rectangle material="Al(0.3)GaAs:C=1e20" dx="150" dy="0.150"/>
      <rectangle material="GaAs" dx="150" dy="0.150"/>
      <rectangle name="junction" role="active" material="In(0.2)GaAs" dx="150" dy="0.007"/>
      <rectangle material="GaAs" dx="150" dy="0.150"/>
      <rectangle material="Al(0.3)GaAs:Si=5e19" dx="150" dy="1.500"/>
      <rectangle name="substrate" material="GaAs:Si=5e19" dx="150" dy="300"/>
      <zero/>
      <rectangle material="Cu" dx="1000" dy="1000"/>
    </stack>
  </cartesian2d>
</geometry>

<grids>
  <generator name="default" type="rectangular2d" method="divide">
    <postdiv by="2"/>
  </generator>
</grids>

<solvers>
  <thermal name="therm" solver="Static2D" lib="static">
    <geometry ref="main"/>
    <mesh ref="default"/>
    <temperature>
      <condition value="300">
        <place side="bottom"/>
      </condition>
    </temperature>
  </thermal>
  <electrical name="electr" solver="Shockley2D" lib="shockley">
    <geometry ref="main"/>
    <mesh ref="default"/>
    <voltage>
      <condition value="1.0">
        <place side="top" object="top-layer"/>
      </condition>
      <condition value="0.0">
        <place side="bottom" object="substrate"/>
      </condition>
    </voltage>
    <junction beta0="19" js0="1"/>
  </electrical>
</solvers>

<connects>
  <connect out="therm.outTemperature" in="electr.inTemperature"/>
  <connect out="electr.outHeat" in="therm.inHeat"/>
</connects>

<script><![CDATA[
verr = electr.compute()
terr = therm.compute()

while terr > therm.maxerr or verr > electr.maxerr:
    verr = electr.compute()
    terr = therm.compute()

print_log(LOG_INFO, "Calculations finished!")

temp = therm.outTemperature(therm.mesh)
elect = electr.outVoltage(electr.mesh)

plot_field(temp, 12)
plot_geometry(GEO["main"])
colorbar()

figure()
plot_geometry(GEO["main"], margin=0.01)
plot_mesh(electr.mesh)

show()

pos = GEO["main"].get_object_positions(GEO["junction"])[0]
print(GEO["main"].get_object_positions(GEO["junction"]))
junction_mesh = mesh.Rectangular2D(linspace(-150., 150., 1000), [pos.y])
current = electr.outCurrentDensity(junction_mesh)
figure()
plot_profile(-current, comp='y')
ylabel("current density (kA/cm$^2$)")

figure()

plot_field(elect, cmap="inferno")
plot_geometry(GEO.main, color='w')
colorbar()

show()

heatmap
]]></script>

</plask>
