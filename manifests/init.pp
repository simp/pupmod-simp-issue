# Manage /etc/issue and /etc/issue.net
#
# @param profile
#   A pre-included banner that can be used out of the box.
#
#   Will be overridden by `$content` and/or `$net_content`
#
#   Valid values are defined by the `simp_banners` module but the local module
#   has the following mappings for legacy support
#     * default      => Standard, we watch everything
#       * New Option => 'simp'
#     * lite         => We only watch for bad things
#       * New Option => 'simp_lite'
#     * us_doc       => U.S. Department of Commerce
#       * New Option => 'us/department_of_commerce'
#     * us_doc_lite  => U.S. Department of Commerce lite
#       * New Option => 'us/department_of_commerce_lite'
#     * us_dod       => U.S. Department of Defense (STIG Compat)
#       * New Option => 'us/department_of_defense'
#     * us_noaa      => U.S. National Oceanic and Atmospehric
#                       Administration
#       * New Option => 'us/national_oceanic_and_atmospheric_administration'
#
# @param content
#   Defaults to a stock `/etc/issue` file in the module. Provide a custom
#   string or file reference to customize. Follows the `File` resource
#   `content` parameter syntax.
#
# @param source
#   Provide a file resource pointer that can be used to set the source of
#   the file to use for a banner. Cannot be set with $content. Follows the
#   `File` resource `source` parameter syntax.
#
# @param net_link
#   If set, links `/etc/issue.net` to `/etc/issue`
#
# @param net_content
#   If `$net_link` is `false`, this content will be written to the
#   `/etc/issue.net` file on the system. Follows the `File` resource `content`
#   parameter syntax.
#
class issue (
  String                                            $profile     = 'default',
  Optional[String]                                  $content     = undef,
  Optional[Pattern[/^puppet:/, /^file:/, /^http:/]] $source      = undef,
  Boolean                                           $net_link    = true,
  Optional[String]                                  $net_content = undef
) {
  simplib::assert_metadata($module_name)

  # This is needed for backward compatibility
  $_valid_profiles = {
    'default'     => 'simp',
    'lite'        => 'simp_lite',
    'us_doc'      => 'us/department_of_commerce',
    'us_doc_lite' => 'us/department_of_commerce_lite',
    'us_dod'      => 'us/department_of_defense',
    'us_noaa'     => 'us/national_oceanic_and_atmospheric_administration',
    'us_disa'     => 'us/defense_information_systems_agency'
  }

  # Default to content if set, otherwise, check source then use the
  # profile.
  if $content {
    $_content = $content
    $_source  = undef
  }
  elsif $source {
    $_content = undef
    $_source  = $source
  }
  else {
    if $profile in keys($_valid_profiles) {
      $_content = simp_banners::fetch($_valid_profiles[$profile])
    }
    else {
      $_content = simp_banners::fetch($profile)
    }
    $_source = undef
  }

  $net_source = $net_link ? {
    true    => 'file:///etc/issue',
    default => undef
  }

  if !$net_link and !$net_content {
    fail('If "$net_link" is false, "$net_content" needs to be provided.')
  }

  file { '/etc/issue':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    source  => $_source,
    content => $_content
  }

  file { '/etc/issue.net':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => $net_content,
    source  => $net_source,
    require => File['/etc/issue']
  }
}
