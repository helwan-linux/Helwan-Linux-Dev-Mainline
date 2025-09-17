#!/usr/bin/env bash
# Helwan Linux pre-build setup script
# يجهز النظام قبل إنشاء ISO

set -euo pipefail

## --------------------------------------------------------------
## 1️⃣ إعداد اسم التوزيعة والنسخة
cat > /etc/lsb-release <<-EOF
DISTRIB_ID="HelwanLinux"
DISTRIB_RELEASE="rolling"
DISTRIB_DESCRIPTION="Helwan Linux"
EOF

cat > /etc/os-release <<-EOF
NAME="HelwanLinux"
PRETTY_NAME="Helwan Linux"
ID=helwan
BUILD_ID=rolling
EOF

echo "HelwanLinux" > /etc/hostname

## --------------------------------------------------------------
## 2️⃣ ضبط المستودعات
cat > /etc/pacman.d/mirrorlist <<-EOF
# مثال لمرايا سريعة
Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
Server = https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch
EOF

# تفعيل multilib
grep -qxF '[multilib]' /etc/pacman.conf || {
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
}

# إضافة مستودعات Helwan الخاصة
grep -qxF '[helwan]' /etc/pacman.conf || {
    echo -e "\n[helwan]\nSigLevel = Never\nServer = https://pkgs.helwan.info/\$arch" >> /etc/pacman.conf
}

## --------------------------------------------------------------
## 3️⃣ إعداد اللغة والمنطقة الزمنية
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

cat > /etc/locale.conf <<-EOF
LANG=zh_CN.UTF-8
LC_ALL=zh_CN.UTF-8
EOF

## --------------------------------------------------------------
## 4️⃣ تفعيل الخدمات الأساسية
for svc in NetworkManager docker; do
    ln -sf "/usr/lib/systemd/system/$svc.service" "/etc/systemd/system/multi-user.target.wants/$svc.service"
done

## --------------------------------------------------------------
## 5️⃣ تحسين تجربة VM (اختياري)
for svc in vboxservice vmtoolsd vmware-networks vmware-vmblock-fuse; do
    if [ -f "/usr/lib/systemd/system/$svc.service" ]; then
        ln -sf "/usr/lib/systemd/system/$svc.service" "/etc/systemd/system/multi-user.target.wants/$svc.service"
    fi
done

## --------------------------------------------------------------
## 6️⃣ إعدادات واجهة المستخدم
# GRUB theme
echo 'GRUB_THEME="/usr/share/grub/themes/helwan-grub-theme-dark-1080p/theme.txt"' >> /etc/default/grub
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

# fcitx5 كمدخل للغة
cat >> /etc/environment <<-EOF
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
EOF

echo "✅ Helwan Linux pre-build setup script completed."
