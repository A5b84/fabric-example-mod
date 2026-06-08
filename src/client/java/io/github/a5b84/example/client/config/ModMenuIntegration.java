package io.github.a5b84.example.client.config;

import com.terraformersmc.modmenu.api.ConfigScreenFactory;
import com.terraformersmc.modmenu.api.ModMenuApi;
import io.github.a5b84.example.config.ExampleModConfig;
import me.shedaniel.autoconfig.AutoConfigClient;

public class ModMenuIntegration implements ModMenuApi {

    @Override
    public ConfigScreenFactory<?> getModConfigScreenFactory() {
        return parent -> AutoConfigClient.getConfigScreen(ExampleModConfig.class, parent).get();
    }
}
