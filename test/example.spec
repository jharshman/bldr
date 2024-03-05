%define name {{ name }}
%define version {{ version }}
%define release {{ release }}

Name: %{name}
Version: %{version}
Release: %{release}
Packager: {{ packager }}
Summary: {{ summary }}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}
BuildRequires: {{ requires }}

%description
{{ description }}

%build

%install

%post

%clean

%files

