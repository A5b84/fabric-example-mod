package io.github.a5b84.example;

import io.github.a5b84.example.config.ExampleModConfig;
import me.shedaniel.autoconfig.AutoConfig;
import me.shedaniel.autoconfig.serializer.GsonConfigSerializer;
import net.fabricmc.api.ClientModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ExampleMod implements ClientModInitializer {

    public static final String MOD_ID = "modid";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    public static ExampleModConfig config;

    @Override
    public void onInitializeClient() {
        AutoConfig.register(ExampleModConfig.class, GsonConfigSerializer::new);
        config = AutoConfig.getConfigHolder(ExampleModConfig.class).getConfig();
    }

}
