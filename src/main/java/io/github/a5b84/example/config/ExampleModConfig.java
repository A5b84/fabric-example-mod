package io.github.a5b84.example.config;

import io.github.a5b84.example.ExampleMod;
import me.shedaniel.autoconfig.ConfigData;
import me.shedaniel.autoconfig.annotation.Config;

@Config(name = ExampleMod.MOD_ID)
public class ExampleModConfig implements ConfigData {

    public String something = "example";

}
