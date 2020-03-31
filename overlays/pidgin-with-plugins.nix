self: super: {
  pidgin-with-plugins = super.pidgin-with-plugins.override {
    plugins = with super; [
      pidgin-sipe
      pidgin-skypeweb
      purple-facebook
      purple-hangouts
      purple-matrix
      purple-plugin-pack
      telegram-purple
    ];
  };
}
