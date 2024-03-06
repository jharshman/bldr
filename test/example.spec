%define name {{ name }}
%define version {{ version }}
%define release {{ release }}

Name: %{name}
Version: %{version}
Release: %{release}
License: GPLv2
Packager: {{ packager }}
Summary: {{ summary }}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}

%description
{{ description }}

%prep
%setup -q

%build
ls -l %{_builddir}/
/usr/local/go/bin/go build -v main.go

%install

%post

%clean

%files
