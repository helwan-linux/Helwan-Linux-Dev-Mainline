#!/usr/bin/env bash
# Helwan Linux pre-build setup script for Cinnamon
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
## 2️⃣ ضبط المستودعات (مرايا عالمية)
# الاحتفاظ بنسخة احتياطية للملف القديم
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup || true

# تحميل قائمة المرايا العالمية الرسمية
curl -s -o /etc/pacman.d/mirrorlist https://archlinux.org/mirrorlist/all/

# فك التعليقات لاستخدام HTTPS فقط (اختياري)
sed -i 's/^#Server/Server/g' /etc/pacman.d/mirrorlist

# إضافة المستودعات الرئيسية إذا مش موجودة
for repo in core extra multilib; do
    if ! grep -qxF "[$repo]" /etc/pacman.conf; then
        echo -e "\n[$repo]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
    fi
done

# إضافة مستودع Helwan الخاص إذا مش موجود
if ! grep -qxF "[helwan]" /etc/pacman.conf; then
    cat >> /etc/pacman.conf <<-EOF

[helwan]
SigLevel = Never
Server = https://pkgs.helwan.info/\$arch
EOF
fi


## --------------------------------------------------------------

## 3️⃣ إعداد اللغة ودعم العربية والإنجليزية

# توليد اللغات المطلوبة
echo -e "en_US.UTF-8 UTF-8\nar_SA.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

# ضبط اللغة الافتراضية للنظام (الإنجليزية)
cat > /etc/locale.conf <<-EOF
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
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

echo "✅ Helwan Linux pre-build setup script for Cinnamon completed."
