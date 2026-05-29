<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            margin: 0;
            background: #f4f7fb;
            font-family: Arial, sans-serif;
        }

        .admin-wrapper {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 260px;
            background: linear-gradient(180deg, #0f172a, #1e293b);
            color: #fff;
            padding: 24px 18px;
            box-shadow: 4px 0 18px rgba(0, 0, 0, 0.08);
        }

        .sidebar-title {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 30px;
            text-align: center;
            color: #2dd4bf;
        }

        .sidebar .nav-link {
            color: #cbd5e1;
            padding: 12px 16px;
            border-radius: 12px;
            margin-bottom: 10px;
            transition: all 0.25s ease;
            font-weight: 500;
        }

        .sidebar .nav-link:hover {
            background: rgba(45, 212, 191, 0.15);
            color: #ffffff;
            transform: translateX(4px);
        }

        .sidebar .nav-link.active-link {
            background: #2dd4bf;
            color: #0f172a !important;
            font-weight: 700;
        }

        .logout-btn {
            border-radius: 12px;
            padding: 10px 14px;
            font-weight: 600;
        }

        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: #f8fafc;
        }

        .topbar {
            background: #ffffff;
            padding: 18px 28px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.03);
        }

        .topbar h5 {
            margin: 0;
            font-weight: 700;
            color: #0f172a;
        }

        .topbar .admin-badge {
            background: #2dd4bf;
            color: #0f172a;
            padding: 8px 14px;
            border-radius: 999px;
            font-size: 14px;
            font-weight: 700;
        }

        .content-area {
            padding: 28px;
        }

        .alert {
            border-radius: 14px;
        }

        @media (max-width: 991px) {
            .sidebar {
                width: 220px;
                padding: 20px 14px;
            }

            .content-area {
                padding: 18px;
            }
        }
    </style>
</head>

<body>

    <div class="admin-wrapper">

        <div class="sidebar">
            <div class="sidebar-title">Admin Panel</div>

            <ul class="nav flex-column">
                <li class="nav-item">
                    <a href="{{ route('admin.dashboard') }}"
                        class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active-link' : '' }}">
                        Dashboard
                    </a>
                </li>

                <li class="nav-item">
                    <a href="{{ route('admin.carOwners') }}"
                        class="nav-link {{ request()->routeIs('admin.carOwners') ? 'active-link' : '' }}">
                        Car Owners
                    </a>
                </li>

                <li class="nav-item">
                    <a href="{{ route('admin.garageOwners') }}"
                        class="nav-link {{ request()->routeIs('admin.garageOwners') ? 'active-link' : '' }}">
                        Garage Owners
                    </a>
                </li>

                <li class="nav-item">
                    <a href="{{ route('admin.garages.index') }}"
                        class="nav-link {{ request()->routeIs('admin.garages.*') ? 'active-link' : '' }}">
                        Garages
                    </a>
                </li>

                <li class="nav-item">
                    <a href="{{ route('admin.reservations.index') }}"
                        class="nav-link {{ request()->routeIs('admin.reservations.*') ? 'active-link' : '' }}">
                        Reservations
                    </a>
                </li>

                <li class="nav-item">
                    <a href="{{ route('admin.reports.index') }}"
                        class="nav-link {{ request()->routeIs('admin.reports.*') ? 'active-link' : '' }}">
                        Garage Reports
                    </a>
                </li>

                <li class="nav-item">
                    <a href="{{ route('admin.contact.index') }}"
                        class="nav-link {{ request()->routeIs('admin.contact.*') ? 'active-link' : '' }}">
                        Contact Messages
                    </a>
                </li>
            </ul>

            <form method="POST" action="{{ route('admin.logout') }}" class="mt-4">
                @csrf
                <button class="btn btn-danger w-100 logout-btn">
                    Logout
                </button>
            </form>
        </div>

        <div class="main-content">
            <div class="topbar">
                <h5>Welcome, Admin</h5>
                <div class="admin-badge">Smart Park Admin</div>
            </div>

            <div class="content-area">
                @if(session('success'))
                <div class="alert alert-success shadow-sm">
                    {{ session('success') }}
                </div>
                @endif

                @if(session('error'))
                <div class="alert alert-danger shadow-sm">
                    {{ session('error') }}
                </div>
                @endif

                @yield('content')
            </div>
        </div>

    </div>

</body>

</html>