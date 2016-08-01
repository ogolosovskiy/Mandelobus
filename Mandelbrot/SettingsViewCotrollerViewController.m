//
//  SettingsViewCotrollerViewController.m
//  Mandelbrot
//
//  Created by Oleg Golosovskiy on 30/07/16.
//  Copyright © 2016 Oleg Golosovskiy. All rights reserved.
//

#import "SettingsViewCotrollerViewController.h"
#import "mandelbrot.h"


struct pal_item
{
    enum palletteScheme pallete;
    char const*         name;
};


@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tabler;
@end

@implementation SettingsViewController

NSArray *tableData;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // to do structs inside
    tableData = [NSArray arrayWithObjects:@"Histogramme", @"Smooth red", @"Smooth", @"Smooth2", @"UltraFractals", nil];
    
   _tabler.delegate = self;
   _tabler.dataSource = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* text = [tableData objectAtIndex:indexPath.row];
    NSString *palName = fromPalette(curScheme);
    if ([palName isEqual: text]) {
        [cell setSelected:YES animated:NO];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    
    NSString *segue_id = [segue identifier];
    NSLog(@"SettingsViewController prepareForSegue %@", segue_id );
    
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        [[segue destinationViewController] setText:@"SecondViewController"];
    }
    else
    {
        [super prepareForSegue:segue sender:sender];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* name  = [tableData objectAtIndex:indexPath.row];
    [[self delegate] setPalette : toPalette(name)];
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
