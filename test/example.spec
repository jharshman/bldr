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
Source: hello-v1.0.0.tar.gz

%description
{{ description }}

%prep
%setup -qn hello

%build
/usr/local/go/bin/go build -v main.go

%install

%post

%clean

%files
