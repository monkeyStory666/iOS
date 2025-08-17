import Foundation
import MEGADesignToken
import MEGADomain
import MEGAL10n

class FolderLinkTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var folderLink: FolderLinkViewController
    
    @objc class func instantiate(withFolderLink folderLink: FolderLinkViewController) -> FolderLinkTableViewController {
        guard let folderLinkTableVC = UIStoryboard(name: "Links", bundle: nil).instantiateViewController(withIdentifier: "FolderLinkTableViewControllerID") as? FolderLinkTableViewController else {
            fatalError("Could not instantiate FolderLinkTableViewController")
        }

        folderLinkTableVC.folderLink = folderLink
        
        return folderLinkTableVC
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.folderLink = FolderLinkViewController()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIView()
        
        // 确保表格视图支持多选编辑模式
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    @IBAction func nodeActionsTapped(_ sender: UIButton) {
        guard !tableView.isEditing,
                let indexPath = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView)),
                let node = getNode(at: indexPath) else {
            return
        }
        
        folderLink.showActions(for: node, from: sender)
    }
    
    @objc func setTableViewEditing(_ editing: Bool, animated: Bool) {
        // 修复：确保正确设置编辑模式
        tableView.setEditing(editing, animated: animated)
        
        // 确保多选模式在编辑时启用
        if editing {
            tableView.allowsMultipleSelectionDuringEditing = true
        }
        
        folderLink.setViewEditing(editing)
        folderLink.setNavigationBarButton(editing)
        
        // 修复：为所有可见单元格设置正确的背景视图
        tableView.visibleCells.forEach { (cell) in
            if let nodeCell = cell as? NodeTableViewCell {
                configureCellForEditing(nodeCell, editing: editing)
            }
        }
    }
    
    private func configureCellForEditing(_ cell: NodeTableViewCell, editing: Bool) {
        if editing {
            // 修复：确保单选按钮区域不被遮挡
            let view = UIView()
            view.backgroundColor = .clear
            cell.selectedBackgroundView = view
            
            // 确保单元格内容不会覆盖单选按钮
            cell.contentView.clipsToBounds = false
        } else {
            cell.selectedBackgroundView = nil
            cell.contentView.clipsToBounds = true
        }
    }
    
    private func getNode(at indexPath: IndexPath) -> MEGANode? {
        return nodes[safe: indexPath.row]
    }
    
    @objc func reload(node: MEGANode) {
        if MEGAReachabilityManager.isReachable() {
            tableView.reloadData()
        } else {
            tableView.reloadData()
        }
    }
    
    @objc func reloadData() {
        tableView.reloadData()
    }
    
    private var nodes: [MEGANode] {
        return folderLink.nodesArray
    }
}

// MARK: - UITableViewDataSource

extension FolderLinkTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "nodeCell", for: indexPath) as? NodeTableViewCell,
              let node = getNode(at: indexPath) else {
            return UITableViewCell()
        }
        
        config(cell, by: node, at: indexPath)
        
        return cell
    }
    
    private func config(_ cell: NodeTableViewCell, by node: MEGANode, at indexPath: IndexPath) {
        if node.isFile() {
            if node.hasThumbnail() {
                Helper.thumbnail(for: node, api: MEGASdk.sharedFolderLink, cell: cell)
            } else {
                cell.thumbnailImageView.image = NodeAssetsManager.shared.icon(for: node)
            }
            cell.infoLabel.text = Helper.sizeAndModificationDate(for: node, api: MEGASdk.sharedFolderLink)
        } else if node.isFolder() {
            cell.thumbnailImageView.image = NodeAssetsManager.shared.icon(for: node)
            cell.infoLabel.text = Helper.filesAndFolders(inFolderNode: node, api: MEGASdk.sharedFolderLink)
        }
        
        cell.thumbnailPlayImageView.isHidden = node.name?.fileExtensionGroup.isVideo != true
        cell.nameLabel.text = node.name
        cell.nameLabel.textColor = TokenColors.Text.primary
        cell.node = node
        
        // 修复：正确处理编辑模式下的选择状态
        if tableView.isEditing {
            // 检查节点是否已被选择
            if let selectedNodes = folderLink.selectedNodesArray as? [MEGANode],
               selectedNodes.contains(where: { $0.handle == node.handle }) {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
            
            // 配置单元格的编辑状态
            configureCellForEditing(cell, editing: true)
        } else {
            configureCellForEditing(cell, editing: false)
        }
        
        cell.separatorView.layer.borderColor = TokenColors.Border.strong.cgColor
        cell.separatorView.layer.borderWidth = 0.5
        
        cell.thumbnailImageView.accessibilityIgnoresInvertColors = true
        cell.thumbnailPlayImageView.accessibilityIgnoresInvertColors = true
        let isDownloaded = node.isFile() && MEGAStore.shareInstance().offlineNode(with: node) != nil
        cell.downloadedView.isHidden = !isDownloaded
    }
}

// MARK: - UITableViewDelegate

extension FolderLinkTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let node = getNode(at: indexPath) else {
            return
        }
        
        if tableView.isEditing {
            // 修复：确保选择操作正确执行
            if folderLink.selectedNodesArray == nil {
                folderLink.selectedNodesArray = NSMutableArray()
            }
            
            // 检查节点是否已经被选择
            if let selectedNodes = folderLink.selectedNodesArray as? [MEGANode],
               !selectedNodes.contains(where: { $0.handle == node.handle }) {
                folderLink.selectedNodesArray?.add(node)
            }
            
            folderLink.setNavigationBarTitleLabel()
            folderLink.setToolbarButtonsEnabled(true)
            folderLink.areAllNodesSelected = folderLink.selectedNodesArray?.count == folderLink.nodesArray.count
            
            // 确保UI正确更新
            tableView.reloadRows(at: [indexPath], with: .none)
            return
        }
        
        folderLink.didSelect(node)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            guard let node = getNode(at: indexPath) else {
                return
            }
            
            // 修复：确保取消选择操作正确执行
            if let selectedNodes = folderLink.selectedNodesArray as? [MEGANode] {
                let nodesToRemove = selectedNodes.filter { $0.handle == node.handle }
                nodesToRemove.forEach { folderLink.selectedNodesArray?.remove($0) }
            }
            
            folderLink.setNavigationBarTitleLabel()
            folderLink.setToolbarButtonsEnabled(folderLink.selectedNodesArray?.count != 0)
            folderLink.areAllNodesSelected = false
            
            // 确保UI正确更新
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        setTableViewEditing(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let contextMenuConfiguration = UIContextMenuConfiguration(identifier: nil) {
            guard let node = self.getNode(at: indexPath) else { return nil }
            if node.isFolder() {
                let folderLinkVC = self.folderLink.fromNode(node)
                return folderLinkVC
            } else {
                return nil
            }
        } actionProvider: { _ in
            let selectAction = UIAction(title: Strings.Localizable.select,
                                        image: UIImage.selectItem) { _ in
                self.setTableViewEditing(true, animated: true)
                self.tableView?.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
                self.tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            return UIMenu(title: "", children: [selectAction])
        }

        return contextMenuConfiguration
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
        guard let folderLinkVC = animator.previewViewController as? FolderLinkViewController else { return }
        animator.addCompletion {
            self.navigationController?.pushViewController(folderLinkVC, animated: true)
        }
    }
    
    // 修复：确保单选按钮区域正确响应
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            // 确保单选按钮可见且可交互
            cell.setEditing(true, animated: false)
            
            if let nodeCell = cell as? NodeTableViewCell {
                configureCellForEditing(nodeCell, editing: true)
            }
        }
    }
}
