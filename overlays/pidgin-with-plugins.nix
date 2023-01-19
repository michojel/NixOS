self: super: {
  pidgin = super.pidgin.override {
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
