# Manage /etc/issue and /etc/issue.net
#
# @param profile
#   A pre-included banner that can be used out of the box.
#
#   Will be overridden by `$content` and/or `$net_content`
#
#   Valid values include:
#     * default     => Standard, we watch everything
#     * lite        => We only watch for bad things
#     * us_doc      => U.S. Department of Commerce
#     * us_doc_lite => U.S. Department of Commerce lite
#     * us_dod      => U.S. Department of Defense (STIG Compat)
#     * us_noaa     => U.S. National Oceanic and Atmospehric
#                      Administration
#
# @param content
#   Defaults to a stock `/etc/issue` file in the module. Provide a custom
#   string or file reference to customize. Follows the `File` resource
#   `content` parameter syntax.
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
  String           $profile     = 'default',
  Optional[String] $content     = undef,
  Boolean          $net_link    = true,
  Optional[String] $net_content = undef
) {
  $_valid_profiles = [
    'default',
    'lite',
    'us_doc',
    'us_doc_lite',
    'us_dod',
    'us_noaa'
  ]

  if $content {
    $_content = $content
  }
  else {
    if $profile in $_valid_profiles {
      $_content = file("${module_name}/issue/${profile}")
    }
    else {
      $_valid_profile_string = join($_valid_profiles,', ')
      fail("You must choose a valid profile ${_valid_profile_string}")
    }
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
