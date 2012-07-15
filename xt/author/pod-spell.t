use strict;
use warnings;
use Test::More;

# generated by Dist::Zilla::Plugin::Test::PodSpelling 2.002005
eval "use Test::Spelling 0.12; use Pod::Wordlist::hanekomu; 1" or die $@;

set_spell_cmd('aspell list');
add_stopwords(<DATA>);
all_pod_files_spelling_ok('bin', 'lib');
__DATA__
PASSed
VCS
repos
psgi
auth
Jeffrey
Ryan
Thalhammer
Imaginative
Software
Systems
lib
Pinto
Server
Router
Responder
File
Action
Index
