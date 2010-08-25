package FileLister;
use strict;

sub new {
  my($cls,@root) = @_;
  push @root, "." unless @root;
  return bless {build=>0,               # include build subtrees identified by presence of "include-staging"?
		edg=>0,                 # enter the EDG_* directories containing C/C++ parser source code?
		thirdparty=>0,          # software not "owned by" ROSE developers, other than EDG which is handled above
		generated=>0,           # software that is machine-generated
                pending=>\@root,        # files and directories that are pending
               }, $cls;
}

# Return true if the given file or directory (with path) is third-party software.
sub is_3rdparty {
  local($_) = @_;
  return 1 if m(/alt-mpi-headers/mpich-([\d\.]+)(p\d)?(/|$)); # in projects/compass/src/util/MPIAbstraction
  return 1 if m(/src/3rdPartyLibraries(/|$));
  return 0;
}

# Return true if the given file or directory (with path) is machine-generated code.
sub is_generated {
  local($_) = @_;
  return 1 if m(/projects/compass/tools/compass/buildCheckers\.C$);
  return 1 if m(/projects/compass/tools/compassVerifier/buildCheckers\.C$);
  return 1 if m(/projects/compass/tools/sampleCompassSubset/buildCheckers\.C$);
  return 1 if m(/src/frontend/SageIII/ompparser\.h$);
  return 1 if m(/src/roseIndependentSupport/dot2gml/parseDotGrammar\.h$);
  return 0;
}

# Return the next name, or undef when we reach the end.
sub next_name {
  my($self) = @_;
  my $retval = shift @{$self->{pending}};
  if ((!$self->{build}      && -d "$retval/include-staging") ||
      (!$self->{edg}        && $retval =~ /\/EDG_[\d\.]+$/ && -d $retval) ||
      (!$self->{thirdparty} && is_3rdparty($retval)) ||
      (!$self->{generated}  && is_generated($retval)) ||
      ($retval =~ /\/libltdl$/ && -d $retval) || # generated by $ROSE_SRC/build" script, we have no control over its contents
      ($retval =~ /\/.git$/ && -d $retval) ||    # no need to ever descend into Git meta data
      ($retval =~ /~$/      && ! -d $retval)     # editor backup files
     ) {
    return $self->next_name; # skip this name, return the next one
  } elsif (opendir DIR, $retval) {
    # Change 'unshift' to 'push' to get a breadth-first search
    unshift @{$self->{pending}}, map {"$retval/$_"} grep {!/^\.\.?$/} sort readdir DIR;
    close DIR;
  }
  return $retval;
}

# Return next name, skipping over directories
sub next_file {
  my($self) = @_;
  while (1) {
    my $retval = $self->next_name;
    return $retval unless -d $retval;
  }
}

# Return the next directory, skipping over non-directories
sub next_dir {
  my($self) = @_;
  while (1) {
    my $retval = $self->next_name;
    return unless defined $retval;
    return $retval if -d $retval;
  }
}

sub all {
  my($self,$code) = @_;
  my(@retval,$entry);
  push @retval, $entry while defined($entry=&{$code});
  return @retval;
}

# Returns all names
sub all_names {
  my($self) = @_;
  return $self->all(sub {$self->next_name});
}

# Return all files (non-directories)
sub all_files {
  my($self) = @_;
  return $self->all(sub {$self->next_file});
}

# Return all directories
sub all_dirs {
  my($self) = @_;
  return $self->all(sub {$self->next_dir});
}

1;
