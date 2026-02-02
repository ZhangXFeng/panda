// Panda 装修管家 - 交互逻辑

// 页面切换
function switchPage(pageId) {
    // 隐藏所有页面
    document.querySelectorAll('.page').forEach(page => {
        page.classList.remove('active');
    });

    // 显示目标页面
    const targetPage = document.getElementById(pageId);
    if (targetPage) {
        targetPage.classList.add('active');
    }

    // 更新标签栏状态
    document.querySelectorAll('.tab-item').forEach(tab => {
        tab.classList.remove('active');
        if (tab.dataset.page === pageId) {
            tab.classList.add('active');
        }
    });

    // 滚动到顶部
    window.scrollTo(0, 0);
}

// 标签栏点击事件
document.querySelectorAll('.tab-item').forEach(tab => {
    tab.addEventListener('click', () => {
        const pageId = tab.dataset.page;
        switchPage(pageId);
    });
});

// 卡片"查看详情"点击事件
document.querySelectorAll('.card-action').forEach(action => {
    action.addEventListener('click', (e) => {
        const card = e.target.closest('.card');
        const cardTitle = card.querySelector('.card-title').textContent;

        // 根据卡片标题跳转到对应页面
        if (cardTitle.includes('预算')) {
            switchPage('budget');
        } else if (cardTitle.includes('进度')) {
            switchPage('schedule');
        }
    });
});

// 快捷操作点击事件
document.querySelectorAll('.quick-action').forEach(action => {
    action.addEventListener('click', (e) => {
        const label = e.currentTarget.querySelector('.quick-action-label').textContent;

        if (label === '记一笔') {
            alert('打开记账页面（待实现）');
        } else if (label === '写日记') {
            alert('打开日记页面（待实现）');
        } else if (label === '通讯录') {
            alert('打开通讯录页面（待实现）');
        } else if (label === '合同文档') {
            alert('打开合同文档页面（待实现）');
        } else if (label === '装修日记') {
            alert('打开装修日记页面（待实现）');
        } else if (label === '数据导出') {
            alert('打开数据导出页面（待实现）');
        }
    });
});

// 悬浮按钮点击事件
document.querySelectorAll('.btn-fab').forEach(btn => {
    btn.addEventListener('click', () => {
        alert('打开记账页面（待实现）');
    });
});

// 列表项点击事件
document.querySelectorAll('.list-item').forEach(item => {
    item.addEventListener('click', (e) => {
        // 如果点击的不是按钮，则显示详情
        if (!e.target.closest('button')) {
            const title = item.querySelector('.list-item-title')?.textContent || '详情';
            console.log('点击列表项:', title);
            // 这里可以添加更多交互逻辑
        }
    });
});

// 预算分类点击事件
document.querySelectorAll('.budget-category').forEach(category => {
    category.addEventListener('click', (e) => {
        const categoryName = e.currentTarget.querySelector('.budget-category-name').textContent;
        alert(`查看 ${categoryName} 详细支出（待实现）`);
    });
});

// 材料卡片点击事件
document.querySelectorAll('.material-card').forEach(card => {
    card.addEventListener('click', (e) => {
        const materialName = e.currentTarget.querySelector('.material-name').textContent;
        alert(`查看 ${materialName} 详情（待实现）`);
    });
});

// 筛选标签点击事件
document.querySelectorAll('.filter-tab').forEach(tab => {
    tab.addEventListener('click', (e) => {
        // 移除同组其他标签的active状态
        const parentContainer = e.target.parentElement;
        parentContainer.querySelectorAll('.filter-tab').forEach(t => {
            t.classList.remove('active');
        });

        // 添加active状态
        e.target.classList.add('active');

        const filterText = e.target.textContent;
        console.log('筛选:', filterText);
    });
});

// 任务勾选框点击事件
document.querySelectorAll('.task-item').forEach(item => {
    item.addEventListener('click', (e) => {
        const title = item.querySelector('.task-title');
        if (title) {
            const isCompleted = title.textContent.includes('✅');
            if (isCompleted) {
                title.textContent = title.textContent.replace('✅', '☐');
                item.style.opacity = '1';
            } else {
                title.textContent = title.textContent.replace('☐', '✅');
                item.style.opacity = '0.6';
            }
        }
    });
});

// 待办事项点击事件
document.querySelectorAll('#home .list-item').forEach(item => {
    item.addEventListener('click', (e) => {
        const title = item.querySelector('.list-item-title');
        if (title) {
            const text = title.textContent;
            if (text.includes('☐')) {
                title.textContent = text.replace('☐', '✅');
                item.style.opacity = '0.6';
                item.style.textDecoration = 'line-through';
            } else if (text.includes('✅')) {
                title.textContent = text.replace('✅', '☐');
                item.style.opacity = '1';
                item.style.textDecoration = 'none';
            }
        }
    });
});

// 动画效果 - 圆环进度条
function animateCircleProgress() {
    const circleProgressFill = document.querySelector('.circle-progress-fill');
    if (circleProgressFill) {
        const percent = 51.4; // 当前进度
        const circumference = 314.16; // 2 * Math.PI * radius (r=50)
        const offset = circumference - (percent / 100) * circumference;

        setTimeout(() => {
            circleProgressFill.style.strokeDashoffset = offset;
        }, 100);
    }
}

// 页面加载完成后执行
document.addEventListener('DOMContentLoaded', () => {
    console.log('Panda 装修管家原型已加载');

    // 动画初始化
    animateCircleProgress();

    // 添加页面切换动画
    document.querySelectorAll('.page').forEach(page => {
        page.style.transition = 'opacity 0.3s ease';
    });
});

// 防止移动端双击缩放
let lastTouchEnd = 0;
document.addEventListener('touchend', (e) => {
    const now = Date.now();
    if (now - lastTouchEnd <= 300) {
        e.preventDefault();
    }
    lastTouchEnd = now;
}, false);

// 模拟数据更新
function updateBudgetData() {
    // 这里可以添加模拟数据更新的逻辑
    console.log('更新预算数据');
}

function updateScheduleData() {
    // 这里可以添加模拟进度更新的逻辑
    console.log('更新进度数据');
}

// 导出功能函数
window.PandaApp = {
    switchPage,
    updateBudgetData,
    updateScheduleData
};
