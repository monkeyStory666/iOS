import Foundation
import UIKit
import SwiftUI

/// 线程安全的UI更新工具类
/// 确保所有UI操作都在主线程执行，避免SwiftUI异步渲染线程崩溃
@MainActor
class ThreadSafeUIUpdater {
    
    // MARK: - Singleton
    static let shared = ThreadSafeUIUpdater()
    
    private init() {}
    
    // MARK: - UI Update Methods
    
    /// 安全地在主线程执行UI更新
    /// - Parameter block: 要执行的UI更新代码块
    static func performOnMainThread(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    /// 安全地在主线程执行UI更新并返回结果
    /// - Parameter block: 要执行的UI更新代码块
    /// - Returns: 更新结果
    static func performOnMainThread<T>(_ block: @escaping () -> T) async -> T {
        if Thread.isMainThread {
            return block()
        } else {
            return await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    let result = block()
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    /// 延迟执行UI更新
    /// - Parameters:
    ///   - delay: 延迟时间（秒）
    ///   - block: 要执行的UI更新代码块
    static func performOnMainThreadAfter(delay: TimeInterval, _ block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            block()
        }
    }
    
    /// 批量UI更新，确保所有更新都在同一个主线程周期内执行
    /// - Parameter updates: 要执行的UI更新代码块数组
    static func performBatchUpdates(_ updates: [() -> Void]) {
        performOnMainThread {
            updates.forEach { $0() }
        }
    }
    
    /// 同步执行UI更新（用于deinit等必须同步完成的场景）
    /// - Parameter block: 要执行的UI更新代码块
    static func performOnMainThreadSync(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }
}

// MARK: - UIView Extensions
extension UIView {
    
    /// 安全地更新UIView的属性
    /// - Parameter block: 更新代码块
    func safeUpdateUI(_ block: @escaping () -> Void) {
        ThreadSafeUIUpdater.performOnMainThread {
            block()
        }
    }
    
    /// 安全地设置hidden属性
    /// - Parameter hidden: 是否隐藏
    func safeSetHidden(_ hidden: Bool) {
        safeUpdateUI {
            self.isHidden = hidden
        }
    }
    
    /// 安全地设置alpha属性
    /// - Parameter alpha: 透明度值
    func safeSetAlpha(_ alpha: CGFloat) {
        safeUpdateUI {
            self.alpha = alpha
        }
    }
    
    /// 安全地设置backgroundColor
    /// - Parameter color: 背景颜色
    func safeSetBackgroundColor(_ color: UIColor?) {
        safeUpdateUI {
            self.backgroundColor = color
        }
    }
}

// MARK: - UIButton Extensions
extension UIButton {
    
    /// 安全地设置按钮标题
    /// - Parameters:
    ///   - title: 标题文本
    ///   - state: 按钮状态
    func safeSetTitle(_ title: String?, for state: UIControl.State) {
        safeUpdateUI {
            self.setTitle(title, for: state)
        }
    }
    
    /// 安全地设置按钮图片
    /// - Parameters:
    ///   - image: 图片
    ///   - state: 按钮状态
    func safeSetImage(_ image: UIImage?, for state: UIControl.State) {
        safeUpdateUI {
            self.setImage(image, for: state)
        }
    }
    
    /// 安全地设置按钮是否启用
    /// - Parameter enabled: 是否启用
    func safeSetEnabled(_ enabled: Bool) {
        safeUpdateUI {
            self.isEnabled = enabled
        }
    }
}

// MARK: - UIImageView Extensions
extension UIImageView {
    
    /// 安全地设置图片
    /// - Parameter image: 要设置的图片
    func safeSetImage(_ image: UIImage?) {
        safeUpdateUI {
            self.image = image
        }
    }
    
    /// 安全地设置图片并添加动画
    /// - Parameters:
    ///   - image: 要设置的图片
    ///   - duration: 动画持续时间
    ///   - options: 动画选项
    func safeSetImageWithAnimation(_ image: UIImage?, duration: TimeInterval = 0.3, options: UIView.AnimationOptions = .transitionCrossDissolve) {
        safeUpdateUI {
            UIView.transition(with: self, duration: duration, options: options) {
                self.image = image
            }
        }
    }
}

// MARK: - UILabel Extensions
extension UILabel {
    
    /// 安全地设置文本
    /// - Parameter text: 要设置的文本
    func safeSetText(_ text: String?) {
        safeUpdateUI {
            self.text = text
        }
    }
    
    /// 安全地设置属性文本
    /// - Parameter attributedText: 要设置的属性文本
    func safeSetAttributedText(_ attributedText: NSAttributedString?) {
        safeUpdateUI {
            self.attributedText = attributedText
        }
    }
}

// MARK: - SwiftUI View Extensions
extension View {
    
    /// 确保视图更新在主线程执行
    /// - Parameter action: 要执行的操作
    func onMainThread(_ action: @escaping () -> Void) -> some View {
        self.onAppear {
            ThreadSafeUIUpdater.performOnMainThread(action)
        }
    }
    
    /// 延迟执行操作
    /// - Parameters:
    ///   - delay: 延迟时间
    ///   - action: 要执行的操作
    func delayedAction(delay: TimeInterval, _ action: @escaping () -> Void) -> some View {
        self.onAppear {
            ThreadSafeUIUpdater.performOnMainThreadAfter(delay: delay, action)
        }
    }
}

// MARK: - UISearchController Extensions
extension UISearchController {
    
    /// 安全地设置搜索文本
    /// - Parameter text: 搜索文本
    func safeSetSearchText(_ text: String?) {
        ThreadSafeUIUpdater.performOnMainThread {
            self.searchBar.text = text
        }
    }
    
    /// 安全地设置搜索控制器激活状态
    /// - Parameter active: 是否激活
    func safeSetActive(_ active: Bool) {
        ThreadSafeUIUpdater.performOnMainThread {
            self.isActive = active
        }
    }
}

// MARK: - UINavigationItem Extensions
extension UINavigationItem {
    
    /// 安全地设置搜索控制器
    /// - Parameter searchController: 搜索控制器
    func safeSetSearchController(_ searchController: UISearchController?) {
        ThreadSafeUIUpdater.performOnMainThread {
            self.searchController = searchController
        }
    }
}

// MARK: - Usage Examples
#if DEBUG
class ThreadSafeUIUpdaterExamples {
    
    static func exampleUsage() {
        // 基本用法
        ThreadSafeUIUpdater.performOnMainThread {
            // 更新UI代码
            print("UI updated on main thread")
        }
        
        // 延迟执行
        ThreadSafeUIUpdater.performOnMainThreadAfter(delay: 1.0) {
            print("Delayed UI update")
        }
        
        // 批量更新
        ThreadSafeUIUpdater.performBatchUpdates([
            { print("Update 1") },
            { print("Update 2") },
            { print("Update 3") }
        ])
        
        // 同步执行（用于deinit等场景）
        ThreadSafeUIUpdater.performOnMainThreadSync {
            print("Synchronous UI update")
        }
    }
    
    static func asyncExample() async {
        // 异步UI更新
        let result = await ThreadSafeUIUpdater.performOnMainThread {
            return "UI update result"
        }
        print(result)
    }
    
    static func deinitExample() {
        // 在deinit中使用同步更新
        class ExampleClass {
            deinit {
                ThreadSafeUIUpdater.performOnMainThreadSync {
                    // 清理UI资源
                    print("Cleaning up UI resources")
                }
            }
        }
    }
}
#endif 