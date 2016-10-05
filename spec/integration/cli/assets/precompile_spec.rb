RSpec.describe 'hanami assets', type: :cli do
  describe 'precompile' do
    it "precompiles assets" do
      with_project("bookshelf_assets_precompile", gems: ['sass', 'coffee-script']) do
        #
        # Web assets
        #
        write "apps/web/assets/javascripts/application.js.coffee", <<-EOF
class Application
  constructor: () ->
    @init = true
EOF
        write "apps/web/assets/stylesheets/_colors.scss", <<-EOF
$background-color: #f5f5f5;
EOF

        write "apps/web/assets/stylesheets/application.css.scss", <<-EOF
@import 'colors';

body {
  background-color: $background-color;
}
EOF
        #
        # Admin assets
        #
        generate "app admin"
        write "apps/admin/assets/javascripts/dashboard.js.coffee", <<-EOF
class Dashboard
  constructor: (@data) ->
EOF

        # FIXME: remove before release
        replace "config/environment.rb", "Hanami::Container.configure do", "Hanami.configure do"

        #
        # Precompile
        #
        RSpec::Support::Env['HANAMI_ENV'] = 'production'
        # FIXME: database connection shouldn't be required for `assets precompile`
        RSpec::Support::Env['DATABASE_URL'] = "file://#{Pathname.new('db').join('bookshelf')}"

        hanami "assets precompile"

        # rubocop:disable Lint/ImplicitStringConcatenation
        # rubocop:disable Style/FirstParameterIndentation

        #
        # Verify manifest
        #
        expect("public/assets.json").to have_file_content <<-EOF
{"/assets/admin/dashboard.js":{"target":"/assets/admin/dashboard-39744f9626a70683b6c2d46305798883.js","sri":["sha256-1myPVWoqrq+uAVP2DSkmAown+5dm0x61+E3AjlGOKEc="]},"/assets/admin/favicon.ico":{"target":"/assets/admin/favicon-2d931609a81d94071c81890f77209101.ico","sri":["sha256-QxGPbQhTL64Lp6vYed7gabWjwB7Uhxkiztdj7LCU23A="]},"/assets/application.css":{"target":"/assets/application-adb4104884aadde9abfef0bd98ac461e.css","sri":["sha256-S6V565W2In9pWE0uzMASpp58xCg32TN3at3Fv4g9aRA="]},"/assets/application.js":{"target":"/assets/application-bb8f10498d83d401db238549409dc4c5.js","sri":["sha256-9m4OTbWigbDPp4oCe1LZz9isqidvW1c3jNL6mXMj2xs="]},"/assets/favicon.ico":{"target":"/assets/favicon-2d931609a81d94071c81890f77209101.ico","sri":["sha256-QxGPbQhTL64Lp6vYed7gabWjwB7Uhxkiztdj7LCU23A="]}}
EOF

        #
        # Verify web assets (w/ checksum)
        #
        expect("public/assets/application-adb4104884aadde9abfef0bd98ac461e.css").to have_file_content <<-EOF
body {background-color: #f5f5f5}
EOF

        expect("public/assets/application-bb8f10498d83d401db238549409dc4c5.js").to have_file_content \
"""
(function(){var Application;Application=(function(){function Application(){this.init=true;}
return Application;})();}).call(this);
"""

        expect("public/assets/favicon-2d931609a81d94071c81890f77209101.ico").to be_an_existing_file

        #
        # Verify web assets (w/o checksum)
        #
        expect("public/assets/application.css").to have_file_content <<-EOF
body {background-color: #f5f5f5}
EOF

        expect("public/assets/application.js").to have_file_content \
"""
(function(){var Application;Application=(function(){function Application(){this.init=true;}
return Application;})();}).call(this);
"""

        expect("public/assets/favicon.ico").to be_an_existing_file

        #
        # Verify admin assets (w/ checksum)
        #
        expect("public/assets/admin/dashboard-39744f9626a70683b6c2d46305798883.js").to have_file_content \
"""
(function(){var Dashboard;Dashboard=(function(){function Dashboard(data){this.data=data;}
return Dashboard;})();}).call(this);
"""

        expect("public/assets/admin/favicon-2d931609a81d94071c81890f77209101.ico").to be_an_existing_file

        #
        # Verify admin assets (w/o checksum)
        #
        expect("public/assets/admin/dashboard.js").to have_file_content \
"""
(function(){var Dashboard;Dashboard=(function(){function Dashboard(data){this.data=data;}
return Dashboard;})();}).call(this);
"""

        expect("public/assets/admin/favicon.ico").to be_an_existing_file

        # rubocop:enable Lint/ImplicitStringConcatenation
        # rubocop:enable Style/FirstParameterIndentation
      end
    end
  end
end
