//
//  Created by Chris Conover on 4/30/15.
//  Copyright (c) 2015 Chris Conover. All rights reserved.
//

import Foundation
import Swift
import UIKit


/**
Top level implementation that maps `UITableViewDelegate` and `UITableViewDataSource`
 methods to use model based methods of nested `TableBuilderProtocol` based child builders.

 Specifically, it supports any nested child builder that implements that table view delegate protocols,
 it doesn't assume any particular form.  Children may them selves have nested sections,
 and this in fact expected.

 */

public class ModularTableViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {

    public var nestedTableBuilders: [TableBuilderProtocol]! { didSet { tableView.reloadData() }}
    public var tableView:UITableView!

    init(tableView:UITableView) {

        // initialize with builder
        self.tableView = tableView
        super.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    func builderAndIndexPathFor(_ indexPath: IndexPath) -> (builder:TableBuilderProtocol, adjusted:IndexPath) {

        let (builder, adjusted) = builderAndOffset(indexPath.section)
        return (builder, IndexPath(row: indexPath.row, section: adjusted))
    }


    private func builderAndOffset(_ section: Int) -> (TableBuilderProtocol, Int)! {
        let builder = sectionsToBuilders[section]!
        return (builder, section - builder.offset.section)
    }


    var sectionsToBuilders = [Int:TableBuilderProtocol]()


    // sections
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        var section = 0
        for builder in nestedTableBuilders {

            builder.offset = IndexPath(row: 0, section: section)
            let sections = builder.numberOfSections?(in: tableView) ?? 0
            (section ..< section + sections).forEach {
                sectionsToBuilders[$0] = builder
            }
            section += sections
        }

        return section
    }

    //
    // section
    //

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (builder, adjusted) = builderAndOffset(section)
        let title = builder.tableView?(tableView, titleForHeaderInSection: adjusted)
        return title
    }


    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (builder, adjusted) = builderAndOffset(section)
        return builder.tableView(tableView, numberOfRowsInSection: adjusted)
    }


    public func tableView(_ tableView: UITableView, cellForRowAt
        path: IndexPath) -> UITableViewCell {

        let (builder, adjusted) = builderAndIndexPathFor(path)
        return builder.tableView(tableView, cellForRowAt: adjusted)
    }


    //
    // UITableViewDelegate
    //


    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, willDisplay: cell, forRowAt: adjusted)
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let (builder, adjusted) = builderAndOffset(section)
        builder.tableView?(tableView, willDisplayHeaderView: view, forSection: adjusted)
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let (builder, adjusted) = builderAndOffset(section)
        builder.tableView?(tableView, willDisplayFooterView: view, forSection: adjusted)
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, didEndDisplaying: cell, forRowAt: adjusted)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        let (builder, adjusted) = builderAndOffset(section)
        builder.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: adjusted)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        let (builder, adjusted) = builderAndOffset(section)
        builder.tableView?(tableView, didEndDisplayingFooterView: view, forSection: adjusted)
    }


    // Variable height support

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        return builder.tableView?(tableView, heightForRowAt: adjusted) ?? UITableView.automaticDimension
    }


    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let (builder, adjusted) = builderAndOffset(section)
        let height = builder.tableView?(tableView, heightForHeaderInSection: adjusted) ?? UITableView.automaticDimension
        return height
    }


    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let (builder, adjusted) = builderAndOffset(section)
        return builder.tableView?(tableView, heightForFooterInSection: adjusted) ?? UITableView.automaticDimension
    }


    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        return builder.tableView?(tableView, estimatedHeightForRowAt: adjusted) ?? UITableView.automaticDimension
    }


    //    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    //        let (builder, adjusted) = builderAndOffset(section)
    //        return builder.tableView?(tableView, estimatedHeightForHeaderInSection: adjusted) ?? UITableViewAutomaticDimension
    //    }


    //    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
    //        let (builder, adjusted) = builderAndOffset(section)
    //        return builder.tableView?(tableView, estimatedHeightForFooterInSection: adjusted) ?? UITableViewAutomaticDimension
    //    }

    // Section header & footer information. Views are preferred over title should you decide to provide both
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let (builder, adjusted) = builderAndOffset(section)
        return builder.tableView?(tableView, viewForHeaderInSection: adjusted)
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let (builder, adjusted) = builderAndOffset(section)
        return builder.tableView?(tableView, viewForFooterInSection: adjusted)
    }

    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, accessoryButtonTappedForRowWith: adjusted)
    }

    // Selection
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        return builder.tableView?(tableView, shouldHighlightRowAt: adjusted) ?? true
    }

    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, didHighlightRowAt: adjusted)
    }

    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, didUnhighlightRowAt: adjusted)
    }


    // Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath), base = indexPath - adjusted
        let p = builder.tableView?(tableView, willSelectRowAt: adjusted)?.absoluteFrom(base)
        return p
    }

    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath), base = indexPath - adjusted
        let p = builder.tableView?(tableView, willDeselectRowAt: adjusted)?.absoluteFrom(base)
        return p
    }

    // Called after the user changes the selection.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, didSelectRowAt: adjusted)
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, didDeselectRowAt: adjusted)
    }


    // Editing

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        return builder.tableView?(tableView, editingStyleForRowAt: adjusted) ?? .none
    }
    //
    //    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    //        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
    //        return builder.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: adjusted)
    //    }
    //
    //    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
    //        return builder.tableView?(tableView, editActionsForRowAt: adjusted)
    //        }
    //
    //
    //    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    //        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
    //        return builder.tableView?(tableView, shouldIndentWhileEditingRowAt: adjusted) ?? true
    //    }
    //
    //
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, willBeginEditingRowAt: adjusted)
    }

    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, didEndEditingRowAt: adjusted)
    }

    public func tableView(_ tableView: UITableView, commit
        editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, commit: editingStyle, forRowAt: adjusted)
    }



    // Moving/reordering

    //    // Allows customization of the target row for a particular row as it is being moved/reordered
    //    public func tableView(_ tableView: UITableView,
    //                          targetIndexPathForMoveFromRowAtIndexPath source: IndexPath,
    //                          toProposedIndexPath dest: IndexPath) -> IndexPath {
    //
    //        let (builder, adjusted) = builderAndOffset(source.section)
    //        let (builder, adjusted) = builderAndOffset(source.section)
    //
    //        guard source.section == source.section else { return source }
    //
    //        let (builder, adjusted) = builderAndOffset(source.section)
    //        let from = IndexPath(row: source.row, section: source.section)
    //        let to = IndexPath(row: source.row, section: source.section)
    //        let result = builder.tableView?(tableView, targetIndexPathForMoveFromRowAt: from, toProposed: to) ?? to
    //        return IndexPath(row: result?.section, section: dest )
    //    }


    // Indentation

    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        return builder.tableView?(tableView, indentationLevelForRowAt: adjusted) ?? 0
    }


    // Copy/Paste.  All three methods must be implemented by the delegate.

    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        return builder.tableView?(tableView, shouldShowMenuForRowAt: adjusted) ?? false
    }

    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        return builder.tableView?(tableView, canPerformAction: action, forRowAt: adjusted, withSender: sender) ?? false
    }

    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        builder.tableView?(tableView, performAction: action, forRowAt: adjusted, withSender: sender)
    }


    // Focus

    @available(iOS 9.0, *)
    public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        let (builder, adjusted) = builderAndIndexPathFor(indexPath)
        return builder.tableView?(tableView, canFocusRowAt: adjusted) ?? true
    }
}


// MARK: Table

public protocol TableBuilderProtocol: UITableViewDataSource, UITableViewDelegate {
    var offset: IndexPath! { get set }
}


extension TableBuilderProtocol {

    func absolutePathFrom(relative: IndexPath) -> IndexPath {
        return IndexPath(row: relative.row,
                           section: offset.section + relative.section)
    }
}

//var sectionCount: (() -> Int)! { get }
//var section: ((section:Int) -> TableSectionBuilder?)! { get }


/**

 Base section builder that supports layered customization at the section, sub-section, and row level.
 It provides override functions that can be further specialized by derived classes, such as the `TableSectionModel`,
 and provides static factory methods to create these specializd builder classes.

 */
public class TableBuilder: NSObject, TableBuilderProtocol {
    
    public var sectionCount: (() -> Int)!
    public var section: ((Int) -> TableSectionBuilder?)!
    public var offset: IndexPath!

   
    //
    // UITableViewDataSource
    //
    
    // sections
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionCount()
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection s: Int) -> String? {
        return section(s)!.title?()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection s: Int) -> UIView? {
        return section(s)!.header?()
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection s: Int) -> CGFloat {
        return section(s)!.heightForHeader?() ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection s: Int) -> Int {
        return section(s)?.rowCount() ?? 0
    }
    


    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // return a cell from either the row-specific closure
        return section(indexPath.section)?
            .traitForRow?(indexPath)?
            .heightForRow?()
            
            // or section level default closure (which must then exist)
            ?? (section(indexPath.section)?.heightForRows?())
            ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt
        path: IndexPath) -> UITableViewCell {
        
        // return a cell from either the row-specific closure
        return section(path.section)?
            .traitForRow?(path)?
            .buildAndConfigure(tableView: tableView, path: path)
            
            // or section level default closure (which must then exist)
            ?? (section(path.section)?.buildRow!(path))!
    }
    

    //
    // UITableViewDelegate
    //
    
    
    
    public func tableView(_ tableView: UITableView, willSelectRowAt path: IndexPath) -> IndexPath? {
        
        // row handler
        if let willSelectRow = section(path.section)?.traitForRow?(path)?.willSelectRowInTable {
            return willSelectRow(path, tableView)
        }
            
            // section handler
        else if let willSelectRowInTable = section(path.section)?.willSelectRowInTable {
            return willSelectRowInTable(path, tableView)
        }
        
        return path
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
        
        if let didSelectRow = section(path.section)?.traitForRow?(path)?.didSelectRowInTable {
            didSelectRow(path, tableView)
        }
            
        else {
            // or section level default closure (which must then exist)
            section(path.section)?.didSelectRowInTable?(path, tableView)
        }
    }
    
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt path: IndexPath) -> IndexPath? {
        
        // row
        if let willDeselectRow = section(path.section)?.traitForRow?(path)?.willDeselectRowInTable {
            return willDeselectRow(path, tableView)
        }
            
        // section
        else if let willDeselectRow = section(path.section)?.willDeselectRowInTable {
            return willDeselectRow(path, tableView)
        }
        
        // default
        return path
    }
    
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt path: IndexPath) {
        
        // row
        if let didDeselectRow = section(path.section)?.traitForRow?(path)?.didDeselectRowInTable {
            didDeselectRow(path, tableView)
        }
            
            // section
        else {
            // or section level default closure (which must then exist)
            section(path.section)?
                .didDeselectRowInTable?(path, tableView)
        }
    }
    

    
    override public init() { super.init() }
    public init(configure: (TableBuilder) -> ()) {
        super.init()
        configure(self)
    }
    
    public class func with(configure: (TableBuilder) -> ()) -> TableBuilder {
        return TableBuilder(configure: configure)
    }
    
    public class func withStaticTableBuilder(configure: (StaticTableBuilder)->()) -> TableBuilder {
        let builder =  StaticTableBuilder()
        configure(builder)
        return builder
    }
    
    public class func withSections(sections:[TableSectionBuilder?]) -> TableBuilder {
        return StaticTableBuilder(sections: sections)
    }
}



// MARK: Section



public protocol TableSectionBuilderProtocol {
	
    // section level attributes
	var header:(() -> UIView?)? { get }
	var title:(() -> String?)? { get }
    var heightForHeader:(() -> CGFloat?)? { get }
	
    // row level attributes
	var rowCount:() -> Int { get }
    var heightForRows:(() -> CGFloat?)? { get }
	var buildRow: ((IndexPath) -> UITableViewCell)? { get }

	var willSelectRowInTable: ((IndexPath, UITableView) -> IndexPath?)? { get }
	var didSelectRowInTable: ((IndexPath, UITableView) -> ())? { get }
	var willDeselectRowInTable: ((IndexPath, UITableView) -> IndexPath?)? { get }
	var didDeselectRowInTable: ((IndexPath, UITableView) -> ())? { get }
	
	// specific builder for row
	var traitForRow: ((IndexPath) -> TableRowTrait?)? { get }
}

/**

 Custom section builder that provides closures to define specific behavior for sections of a
 `ModularTableViewModel` instance. This is usefull at the client level for things like
 dynamic queries, but also forms the basis for a model driven approach in which the closures
 are defined in terms of a known set of static data / cells.

 Example usage:

        modularTableViewModel.nestedChildren =

        TableBuilder.withSections([

            // example of static section
            // (like a form)
            TableSectionBuilder.withModel() { section in

                // general configuration of section
                section.heightForHeader = 0
                section.heightForRows = 60

                // specific model data for static types (forms)
                section.rows = [

                    // specify a custom behavior for a unique cell type
                    TableRowTrait.with() { [unowned self] row in

                        row.build = { tableView, path in
                            // configure cell
                            return cell }
                    },
                ]}


 */
public class TableSectionBuilder : TableSectionBuilderProtocol{
	
	public init() {
		self.rowCount = { 0 }
	}
	
	public var header:(() -> UIView?)?
    public var heightForHeader:(() -> CGFloat?)?
	public var title:(() -> String?)?
	
	public var rowCount:() -> Int
    public var heightForRows:(() -> CGFloat?)?
	
	// section level attributes
    public var buildRow: ((IndexPath) -> UITableViewCell)?
    
	public var willSelectRowInTable: ((IndexPath, UITableView) -> IndexPath?)?
	public var didSelectRowInTable: ((IndexPath, UITableView) -> ())?
	public var willDeselectRowInTable: ((IndexPath, UITableView) -> IndexPath?)?
	public var didDeselectRowInTable: ((IndexPath, UITableView) -> ())?
	
	// specific builder for row
	public var traitForRow: ((IndexPath) -> TableRowTrait?)?
	
	//
	// confiuguration
	//
	
	public class func withModel(configuration configure: (TableSectionModel) ->()) -> TableSectionBuilder {
		
		// create a builder from the returned model
		let model = TableSectionModel()
		configure(model)
		return TableSectionModelBuilder(model:model)
	}
	
	public class func with(configuration configure: (TableSectionBuilder) ->()) -> TableSectionBuilder {
		
		// create a builder from the returned model
		let section = TableSectionBuilder()
		configure(section)
		return section
	}
}


public class TableSectionModelBuilder : TableSectionBuilder {
	
	public init(model: TableSectionModel) {
		self.model = model
		
		super.init()
        header = model.header
		if let title = model.title { self.title = { title } }
        if let height = model.heightForHeader { self.heightForHeader = { height }}
        if let height = model.heightForRows { self.heightForRows = { height }}
		
		self.rowCount = { [unowned self] in self.model.rows.count }
		self.traitForRow = { [unowned self] path in self.model.rows[path.row] }
	}
	
	public var model: TableSectionModel
}


public class TableSectionModel {

    public var heightForHeader: CGFloat?
    public var header:(() -> UIView?)?
    public var title:String?

    public var heightForRows: CGFloat?
    public var rows:[TableRowTrait] = []

    public func title(title:String) -> TableSectionModel {
        self.title = title
        return self;
    }

    public func addRow(rowTrait:TableRowTrait) {
        rows.append(rowTrait)
    }

    public func addRows(newRows:TableRowTrait ...) {
        rows = rows + newRows
    }
}


// MARK: Row

public protocol TableRowTraitProtocol {
    
    associatedtype CellType:UITableViewCell
    
    var heightForRow:(() -> CGFloat?)? { get }
    
    func buildAndConfigure(tableView:UITableView, path:IndexPath) -> CellType?
    var build: ((UITableView, IndexPath) -> CellType)? { get }
    var configure: ((CellType) -> ())? { get }
    
    var willSelectRowInTable: ((IndexPath, UITableView) -> IndexPath?)? { get }
    var didSelectRowInTable: ((IndexPath, UITableView) -> ())? { get }
    var willDeselectRowInTable: ((IndexPath, UITableView) -> IndexPath?)? { get }
    var didDeselectRowInTable: ((IndexPath, UITableView) -> ())? { get }
}


public class TableRowTrait : TableRowTraitProtocol {
    
    public var heightForRow:(() -> CGFloat?)?
    
    final public func buildAndConfigure(tableView:UITableView, path:IndexPath) -> UITableViewCell? {
        if let cell = build?(tableView, path) {
            configure?(cell)
            return cell
        }
        return nil
    }
    
    public var build: ((UITableView, IndexPath) -> UITableViewCell)?
    public var configure: ((UITableViewCell) -> ())?
    
    public var willSelectRowInTable: ((IndexPath, UITableView) -> IndexPath?)?
    public var didSelectRowInTable: ((IndexPath, UITableView) -> ())?
    public var willDeselectRowInTable: ((IndexPath, UITableView) -> IndexPath?)?
    public var didDeselectRowInTable: ((IndexPath, UITableView) -> ())?
    
    public init() {}
    public convenience init(configure: (TableRowTrait) -> ()) {
        self.init()
        configure(self);
    }
    
    public class func with(configuration configure: (TableRowTrait) -> ()) -> TableRowTrait {
        return TableRowTrait(configure:configure)
    }
}


public class StaticTableBuilder : TableBuilder {
	
	override public init() {
		super.init()
        configure()
	}
	
	public convenience init(sections:[TableSectionBuilder?]) {
		
		// configure base implementation
        self.init()
        self.sections = sections.compactMap { $0 }
        configure()
	}
    
    private func configure() {
        self.sectionCount = { [unowned self] in self.sections.count }
        self.section = { [unowned self] section in self.sections[section] }
    }
	
	public func addSection(sectionBuilder:TableSectionBuilder) {
		sections.append(sectionBuilder)
	}
	
	public var sections:[TableSectionBuilder] = []
}


extension IndexPath {
    
    func relativeTo(_ base: IndexPath) -> IndexPath {
        assert(section >= base.section)
        return IndexPath(row: row - base.row, section: section - base.section)
    }

    func absoluteFrom(_ base: IndexPath) -> IndexPath {
        return IndexPath(row: row + base.row, section: section + base.section)
    }
}

func +(lhs:IndexPath, rhs:IndexPath) -> IndexPath {
    return lhs.absoluteFrom(rhs)
}

func -(lhs:IndexPath, rhs:IndexPath) -> IndexPath {
    return lhs.relativeTo(rhs)
}

